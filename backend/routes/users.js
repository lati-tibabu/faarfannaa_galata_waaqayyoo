const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');
const adminSetupMiddleware = require('../middleware/adminSetupMiddleware');

const adminOrEditorMiddleware = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Authentication required.' });
  }
  if (req.user.role !== 'admin' && req.user.role !== 'editor') {
    return res.status(403).json({ error: 'Access denied. Insufficient permissions.' });
  }
  return next();
};

// Routes for users
router.post('/register', userController.register);
router.post('/login', userController.login);
router.get('/me', authMiddleware, userController.getCurrentUser);
router.get('/me/library', authMiddleware, userController.getMyLibrary);
router.get('/me/library/:songId', authMiddleware, userController.getMyLibrarySongStatus);
router.post('/me/library/:songId', authMiddleware, userController.addSongToMyLibrary);
router.delete('/me/library/:songId', authMiddleware, userController.removeSongFromMyLibrary);
router.post('/admin/first-login-setup', authMiddleware, roleMiddleware('admin'), userController.completeAdminFirstLogin);
router.get('/admin/dashboard', authMiddleware, adminOrEditorMiddleware, adminSetupMiddleware, userController.getAdminDashboard);
router.post('/admin/users', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, userController.createManagedUser);
router.post('/admin', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, userController.createAdmin);
router.get('/', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, userController.getAllUsers);
router.get('/:id', authMiddleware, userController.getUserById);
router.post('/', userController.createUser); // maybe keep public for now, or protect
router.put('/:id', authMiddleware, userController.updateUser);
router.delete('/:id', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, userController.deleteUser);

module.exports = router;
