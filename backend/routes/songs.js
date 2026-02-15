const express = require('express');
const router = express.Router();
const songController = require('../controllers/songController');
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');

// Routes for songs
router.get('/seed', songController.seedSongs); // Seed songs from local files
router.get('/recent', songController.getRecentUpdates);
router.get('/', songController.getAllSongs);
router.get('/:id', songController.getSongById);
router.put('/:id', authMiddleware, roleMiddleware('editor'), songController.updateSong);

module.exports = router;