const express = require('express');
const router = express.Router();
const feedbackController = require('../controllers/feedbackController');
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');
const adminSetupMiddleware = require('../middleware/adminSetupMiddleware');

router.post('/', feedbackController.submitAnonymousFeedback);
router.get('/', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, feedbackController.getAllFeedback);
router.patch('/:id/review', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, feedbackController.markFeedbackReviewed);

module.exports = router;
