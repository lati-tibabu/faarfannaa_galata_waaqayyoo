const express = require('express');
const router = express.Router();
const communityController = require('../controllers/communityController');
const authMiddleware = require('../middleware/authMiddleware');
const optionalAuthMiddleware = require('../middleware/optionalAuthMiddleware');

router.get('/posts', optionalAuthMiddleware, communityController.getPosts);
router.post('/posts', authMiddleware, communityController.createPost);
router.post('/posts/:postId/comments', authMiddleware, communityController.addComment);
router.post('/posts/:postId/likes', authMiddleware, communityController.likePost);
router.delete('/posts/:postId/likes', authMiddleware, communityController.unlikePost);
router.delete('/posts/:postId', authMiddleware, communityController.deletePost);
router.delete('/comments/:commentId', authMiddleware, communityController.deleteComment);

module.exports = router;
