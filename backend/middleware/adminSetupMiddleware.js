const { User } = require('../models');

const adminSetupMiddleware = async (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') {
    return next();
  }

  try {
    const admin = await User.findByPk(req.user.id, {
      attributes: ['id', 'first_login'],
    });
    if (!admin) {
      return res.status(401).json({ error: 'Admin user no longer exists.' });
    }
    if (admin.first_login) {
      return res.status(403).json({
        error: 'Admin setup required before continuing.',
        code: 'ADMIN_SETUP_REQUIRED',
      });
    }
    next();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = adminSetupMiddleware;
