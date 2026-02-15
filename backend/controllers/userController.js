const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { Op } = require('sequelize');
const { User, DeviceConnection, SongChange } = require('../models');
const { trackDeviceConnection } = require('../services/deviceTracker');

const jwtSecret = process.env.JWT_SECRET;
const VALID_ROLES = new Set(['user', 'admin', 'editor']);
const PASSWORD_MIN_LENGTH = 6;

const normalizeEmail = (email = '') => email.trim().toLowerCase();
const isStrongEnoughPassword = (password = '') => password.length >= PASSWORD_MIN_LENGTH;
const isUniqueConstraintError = (error) => error?.name === 'SequelizeUniqueConstraintError';

const buildToken = (user) => {
  if (!jwtSecret) {
    throw new Error('Server auth configuration is missing (JWT_SECRET)');
  }
  return jwt.sign({ id: user.id, role: user.role }, jwtSecret, { expiresIn: '1h' });
};

const sanitizeUser = (user) => ({
  id: user.id,
  name: user.name,
  email: user.email,
  role: user.role,
  first_login: Boolean(user.first_login),
  createdAt: user.createdAt,
  updatedAt: user.updatedAt,
});

const userController = {
  // Get all users (admin)
  getAllUsers: async (req, res) => {
    try {
      const users = await User.findAll({
        attributes: { exclude: ['password'] },
        order: [['createdAt', 'DESC']],
      });
      res.json(users);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Get current logged-in user
  getCurrentUser: async (req, res) => {
    try {
      const user = await User.findByPk(req.user.id, {
        attributes: { exclude: ['password'] },
      });
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }
      res.json({ user });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Get user by ID
  getUserById: async (req, res) => {
    try {
      const targetUserId = Number(req.params.id);
      if (req.user.role !== 'admin' && req.user.id !== targetUserId) {
        return res.status(403).json({ error: 'You can only view your own user profile.' });
      }

      const user = await User.findByPk(targetUserId, {
        attributes: { exclude: ['password'] },
      });
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }
      res.json(user);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Create a normal user account (public)
  createUser: async (req, res) => {
    try {
      const { name, email, password } = req.body;
      if (!name || !email || !password) {
        return res.status(400).json({ error: 'Name, email, and password are required' });
      }
      if (!isStrongEnoughPassword(password)) {
        return res.status(400).json({ error: `Password must be at least ${PASSWORD_MIN_LENGTH} characters.` });
      }

      const user = await User.create({
        name: name.trim(),
        email: normalizeEmail(email),
        password: await bcrypt.hash(password, 10),
        role: 'user',
        first_login: false,
      });

      res.status(201).json(sanitizeUser(user));
    } catch (error) {
      if (isUniqueConstraintError(error)) {
        return res.status(409).json({ error: 'Email is already in use.' });
      }
      res.status(500).json({ error: error.message });
    }
  },

  // Login user
  login: async (req, res) => {
    try {
      const { email, username, password } = req.body;
      const rawIdentifier = normalizeEmail(email || username || '');
      if (!rawIdentifier || !password) {
        return res.status(400).json({ error: 'Username/email and password are required' });
      }

      const user = await User.findOne({
        where: {
          [Op.or]: [{ email: rawIdentifier }, { name: rawIdentifier }],
        },
      });
      if (!user) {
        return res.status(400).json({ error: 'Invalid email or password' });
      }

      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res.status(400).json({ error: 'Invalid email or password' });
      }

      await trackDeviceConnection(req, user.id);

      const token = buildToken(user);
      const publicUser = sanitizeUser(user);
      res.json({
        token,
        user: publicUser,
        mustSetupAdmin: user.role === 'admin' && user.first_login,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Register user
  register: async (req, res) => {
    try {
      const { name, email, password } = req.body;
      if (!name || !email || !password) {
        return res.status(400).json({ error: 'Name, email, and password are required' });
      }
      if (!isStrongEnoughPassword(password)) {
        return res.status(400).json({ error: `Password must be at least ${PASSWORD_MIN_LENGTH} characters.` });
      }

      const user = await User.create({
        name: name.trim(),
        email: normalizeEmail(email),
        password: await bcrypt.hash(password, 10),
        role: 'user',
        first_login: false,
      });
      const token = buildToken(user);
      res.status(201).json({ token, user: sanitizeUser(user) });
    } catch (error) {
      if (isUniqueConstraintError(error)) {
        return res.status(409).json({ error: 'Email is already in use.' });
      }
      res.status(500).json({ error: error.message });
    }
  },

  // Create managed user (admin)
  createManagedUser: async (req, res) => {
    try {
      const { name, email, password, role = 'user' } = req.body;
      const normalizedRole = String(role).trim().toLowerCase();

      if (!name || !email || !password) {
        return res.status(400).json({ error: 'Name, email, and password are required.' });
      }
      if (!VALID_ROLES.has(normalizedRole)) {
        return res.status(400).json({ error: 'Invalid role. Allowed roles: user, editor, admin.' });
      }
      if (!isStrongEnoughPassword(password)) {
        return res.status(400).json({ error: `Password must be at least ${PASSWORD_MIN_LENGTH} characters.` });
      }

      const user = await User.create({
        name: name.trim(),
        email: normalizeEmail(email),
        password: await bcrypt.hash(password, 10),
        role: normalizedRole,
        first_login: normalizedRole === 'admin',
      });

      res.status(201).json(sanitizeUser(user));
    } catch (error) {
      if (isUniqueConstraintError(error)) {
        return res.status(409).json({ error: 'Email is already in use.' });
      }
      res.status(500).json({ error: error.message });
    }
  },

  // Create admin user (admin only)
  createAdmin: async (req, res) => {
    req.body.role = 'admin';
    return userController.createManagedUser(req, res);
  },

  // Complete first admin login setup
  completeAdminFirstLogin: async (req, res) => {
    try {
      const { newAdminPassword, editorName, editorEmail, editorPassword } = req.body;
      if (!newAdminPassword || !editorName || !editorEmail || !editorPassword) {
        return res.status(400).json({
          error: 'newAdminPassword, editorName, editorEmail, and editorPassword are required.',
        });
      }
      if (!isStrongEnoughPassword(newAdminPassword) || !isStrongEnoughPassword(editorPassword)) {
        return res.status(400).json({ error: `Passwords must be at least ${PASSWORD_MIN_LENGTH} characters.` });
      }

      const admin = await User.findByPk(req.user.id);
      if (!admin || admin.role !== 'admin') {
        return res.status(403).json({ error: 'Only admins can complete admin setup.' });
      }
      if (!admin.first_login) {
        return res.status(400).json({ error: 'Admin setup is already complete.' });
      }

      const normalizedEditorEmail = normalizeEmail(editorEmail);
      const existingEditorEmail = await User.findOne({ where: { email: normalizedEditorEmail } });
      if (existingEditorEmail) {
        return res.status(409).json({ error: 'Editor email is already in use.' });
      }

      let editor;
      await User.sequelize.transaction(async (transaction) => {
        admin.password = await bcrypt.hash(newAdminPassword, 10);
        admin.first_login = false;
        await admin.save({ transaction });

        editor = await User.create({
          name: editorName.trim(),
          email: normalizedEditorEmail,
          password: await bcrypt.hash(editorPassword, 10),
          role: 'editor',
          first_login: false,
        }, { transaction });
      });

      const token = buildToken(admin);

      res.json({
        message: 'Admin first login setup completed successfully.',
        token,
        user: sanitizeUser(admin),
        editor: sanitizeUser(editor),
        mustSetupAdmin: false,
      });
    } catch (error) {
      if (isUniqueConstraintError(error)) {
        return res.status(409).json({ error: 'Editor email is already in use.' });
      }
      res.status(500).json({ error: error.message });
    }
  },

  // Admin dashboard stats
  getAdminDashboard: async (req, res) => {
    try {
      const activeCutoff = new Date(Date.now() - 24 * 60 * 60 * 1000);

      const [
        totalUsers,
        totalAdmins,
        totalEditors,
        totalRegularUsers,
        totalDevicesSeen,
        activeDevices,
        pendingSongChanges,
        recentDevices,
      ] = await Promise.all([
        User.count(),
        User.count({ where: { role: 'admin' } }),
        User.count({ where: { role: 'editor' } }),
        User.count({ where: { role: 'user' } }),
        DeviceConnection.count(),
        DeviceConnection.count({
          where: {
            lastSeenAt: { [Op.gte]: activeCutoff },
          },
        }),
        SongChange.count({ where: { status: 'pending' } }),
        DeviceConnection.findAll({
          attributes: ['id', 'deviceId', 'ipAddress', 'userAgent', 'firstSeenAt', 'lastSeenAt'],
          include: [
            {
              model: User,
              as: 'user',
              attributes: ['id', 'name', 'email', 'role'],
            },
          ],
          order: [['lastSeenAt', 'DESC']],
          limit: 10,
        }),
      ]);

      res.json({
        stats: {
          totalUsers,
          totalAdmins,
          totalEditors,
          totalRegularUsers,
          totalDevicesSeen,
          activeDevicesLast24Hours: activeDevices,
          pendingSongChanges,
        },
        recentDevices,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Update user
  updateUser: async (req, res) => {
    try {
      const targetUserId = Number(req.params.id);
      const isSelfUpdate = req.user.id === targetUserId;
      const isAdmin = req.user.role === 'admin';

      if (!isAdmin && !isSelfUpdate) {
        return res.status(403).json({ error: 'You can only update your own account.' });
      }

      const user = await User.findByPk(targetUserId);
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      const updates = {};
      const { name, email, password, role, first_login } = req.body;

      if (name !== undefined) {
        updates.name = String(name).trim();
      }
      if (email !== undefined) {
        updates.email = normalizeEmail(email);
      }
      if (password !== undefined) {
        if (!isStrongEnoughPassword(password)) {
          return res.status(400).json({ error: `Password must be at least ${PASSWORD_MIN_LENGTH} characters.` });
        }
        updates.password = await bcrypt.hash(password, 10);
      }

      if (isAdmin && role !== undefined) {
        const normalizedRole = String(role).trim().toLowerCase();
        if (!VALID_ROLES.has(normalizedRole)) {
          return res.status(400).json({ error: 'Invalid role. Allowed roles: user, editor, admin.' });
        }
        updates.role = normalizedRole;
      }

      if (isAdmin && first_login !== undefined) {
        updates.first_login = Boolean(first_login);
      }

      await user.update(updates);
      res.json(sanitizeUser(user));
    } catch (error) {
      if (isUniqueConstraintError(error)) {
        return res.status(409).json({ error: 'Email is already in use.' });
      }
      res.status(500).json({ error: error.message });
    }
  },

  // Delete user
  deleteUser: async (req, res) => {
    try {
      const userIdToDelete = Number(req.params.id);
      if (req.user.id === userIdToDelete) {
        return res.status(400).json({ error: 'You cannot delete your own account while logged in.' });
      }

      const deleted = await User.destroy({
        where: { id: userIdToDelete },
      });
      if (deleted) {
        res.status(204).send();
      } else {
        res.status(404).json({ error: 'User not found' });
      }
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },
};

module.exports = userController;
