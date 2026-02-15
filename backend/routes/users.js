const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');

// Routes for users
router.post('/register', userController.register);
router.post('/login', userController.login);
router.post('/admin', authMiddleware, roleMiddleware('admin'), userController.createAdmin);
router.get('/', authMiddleware, roleMiddleware('admin'), userController.getAllUsers);
router.get('/:id', authMiddleware, userController.getUserById);
router.post('/', userController.createUser); // maybe keep public for now, or protect
router.put('/:id', authMiddleware, userController.updateUser);
router.delete('/:id', authMiddleware, roleMiddleware('admin'), userController.deleteUser);

module.exports = router;