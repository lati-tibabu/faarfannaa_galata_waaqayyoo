const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');
const adminSetupMiddleware = require('../middleware/adminSetupMiddleware');

// Routes for users
router.post('/register', userController.register);
router.post('/login', userController.login);
router.get('/me', authMiddleware, userController.getCurrentUser);
router.post('/admin/first-login-setup', authMiddleware, roleMiddleware('admin'), userController.completeAdminFirstLogin);
router.get('/admin/dashboard', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, userController.getAdminDashboard);
router.post('/admin/users', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, userController.createManagedUser);
router.post('/admin', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, userController.createAdmin);
router.get('/', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, userController.getAllUsers);
router.get('/:id', authMiddleware, userController.getUserById);
router.post('/', userController.createUser); // maybe keep public for now, or protect
router.put('/:id', authMiddleware, userController.updateUser);
router.delete('/:id', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, userController.deleteUser);

module.exports = router;
