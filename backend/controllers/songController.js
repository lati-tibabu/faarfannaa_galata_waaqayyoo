const { Song } = require('../models');
const fs = require('fs');
const path = require('path');

const songController = {
  // Seed songs from local songs folder
  seedSongs: async (req, res) => {
    try {
      const songsDir = path.join(__dirname, '..', 'songs');
      const files = fs.readdirSync(songsDir).filter(file => file.endsWith('.json'));

      const results = [];
      for (const file of files) {
        const filePath = path.join(songsDir, file);
        const songData = JSON.parse(fs.readFileSync(filePath, 'utf8'));

        const { number, title, category, sections } = songData;

        // Upsert song
        const [song, created] = await Song.upsert({
          id: number,
          title,
          category,
          content: { sections }, // Store sections in content
        });

        results.push({ id: song.id, created });
      }

      res.json({
        message: 'Songs seeded successfully',
        count: results.length,
        results
      });
    } catch (error) {
      console.error('Error seeding songs:', error);
      res.status(500).json({ error: error.message });
    }
  },

  // Get all songs
  getAllSongs: async (req, res) => {
    try {
      const songs = await Song.findAll({
        order: [['id', 'ASC']]
      });
      res.json(songs);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Get song by ID
  getSongById: async (req, res) => {
    try {
      const song = await Song.findByPk(req.params.id);
      if (!song) {
        return res.status(404).json({ error: 'Song not found' });
      }
      res.json(song);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Get recent updates
  getRecentUpdates: async (req, res) => {
    try {
      const since = req.query.since ? new Date(req.query.since) : new Date(Date.now() - 7 * 24 * 60 * 60 * 1000); // default last 7 days
      const songs = await Song.findAll({
        where: {
          updatedAt: {
            [require('sequelize').Op.gt]: since
          }
        },
        order: [['updatedAt', 'DESC']]
      });
      res.json(songs);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Update song
  updateSong: async (req, res) => {
    try {
      const { title, category, sections } = req.body;
      const [updated] = await Song.update(
        { title, category, content: { sections } },
        { where: { id: req.params.id } }
      );
      if (updated) {
        const updatedSong = await Song.findByPk(req.params.id);
        res.json(updatedSong);
      } else {
        res.status(404).json({ error: 'Song not found' });
      }
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },
};

module.exports = songController;