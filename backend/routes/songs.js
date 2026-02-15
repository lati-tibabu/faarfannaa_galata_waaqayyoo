const express = require('express');
const router = express.Router();
const songController = require('../controllers/songController');
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');
const adminSetupMiddleware = require('../middleware/adminSetupMiddleware');

// Routes for songs
router.get('/seed', songController.seedSongs); // Seed songs from local files
router.get('/sync', songController.getSyncChanges);
router.get('/recent', songController.getRecentUpdates);
router.get('/changes', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, songController.getSongChanges);
router.post('/changes/:changeId/review', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, songController.reviewSongChange);
router.get('/', songController.getAllSongs);
router.get('/:id', songController.getSongById);
router.put('/:id', authMiddleware, roleMiddleware('editor'), songController.updateSong);
router.delete('/:id', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, songController.deleteSong);

module.exports = router;
