const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const songController = require('../controllers/songController');
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');
const adminSetupMiddleware = require('../middleware/adminSetupMiddleware');

const isProduction = process.env.NODE_ENV === 'production';

if (!isProduction) {
	const uploadDir = path.join(__dirname, '..', 'upload');
	if (!fs.existsSync(uploadDir)) {
		fs.mkdirSync(uploadDir, { recursive: true });
	}
}

const upload = multer({
	storage: multer.memoryStorage(),
	limits: {
		fileSize: 25 * 1024 * 1024,
	},
	fileFilter: (req, file, cb) => {
		if (!file.mimetype || !file.mimetype.startsWith('audio/')) {
			return cb(new Error('Only audio files are allowed.'));
		}
		return cb(null, true);
	},
});

const musicUploadMiddleware = (req, res, next) => {
	upload.single('music')(req, res, (err) => {
		if (!err) {
			return next();
		}
		return res.status(400).json({ error: err.message || 'Invalid music upload request.' });
	});
};

// Routes for songs
router.get('/seed', songController.seedSongs); // Seed songs from local files
router.get('/sync', songController.getSyncChanges);
router.get('/recent', songController.getRecentUpdates);
router.get('/changes', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, songController.getSongChanges);
router.post('/changes/:changeId/review', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, songController.reviewSongChange);
router.get('/', songController.getAllSongs);
router.get('/:id/music', songController.downloadSongMusic);
router.post('/:id/music', authMiddleware, roleMiddleware('editor'), musicUploadMiddleware, songController.uploadSongMusic);
router.delete('/:id/music', authMiddleware, roleMiddleware('editor'), songController.removeSongMusic);
router.get('/:id', songController.getSongById);
router.put('/:id', authMiddleware, roleMiddleware('editor'), songController.updateSong);
router.delete('/:id', authMiddleware, roleMiddleware('admin'), adminSetupMiddleware, songController.deleteSong);

module.exports = router;
