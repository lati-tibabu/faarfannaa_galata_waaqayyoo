const fs = require('fs');
const path = require('path');
const { Op } = require('sequelize');
const { Song, SongChange, SongDeletion, User } = require('../models');

const MUSIC_UPLOAD_DIR = path.join(__dirname, '..', 'upload');
fs.mkdirSync(MUSIC_UPLOAD_DIR, { recursive: true });

const parseSections = (sections) => {
  if (!Array.isArray(sections) || sections.length === 0) {
    return null;
  }

  const normalized = sections
    .map((section) => ({
      type: String(section?.type || '').trim(),
      lines: Array.isArray(section?.lines)
        ? section.lines.map((line) => String(line)).filter((line) => line.trim().length > 0)
        : [],
    }))
    .filter((section) => section.type && section.lines.length > 0);

  if (normalized.length === 0) {
    return null;
  }

  return normalized;
};

const bumpSongVersion = (currentVersion = '1.0') => {
  const [majorRaw, minorRaw = '0'] = String(currentVersion).split('.');
  const major = Number.parseInt(majorRaw, 10);
  const minor = Number.parseInt(minorRaw, 10);
  if (Number.isNaN(major) || Number.isNaN(minor)) {
    return '1.0';
  }
  return `${major}.${minor + 1}`;
};

const serializeSongForSync = (song) => ({
  id: song.id,
  title: song.title,
  category: song.category,
  sections: Array.isArray(song.content?.sections) ? song.content.sections : [],
  version: song.version,
  hasMusic: Boolean(song.hasMusic && song.musicFileName),
  musicUpdatedAt: song.musicUpdatedAt,
  updatedAt: song.lastPublishedAt || song.updatedAt,
});

const deleteMusicFile = (fileName) => {
  if (!fileName) {
    return;
  }
  const absolutePath = path.join(MUSIC_UPLOAD_DIR, fileName);
  if (fs.existsSync(absolutePath)) {
    fs.unlinkSync(absolutePath);
  }
};

const validateSongPayload = ({ title, category, sections }) => {
  const normalizedTitle = String(title || '').trim();
  const normalizedCategory = String(category || '').trim();
  const normalizedSections = parseSections(sections);

  if (!normalizedTitle || !normalizedCategory || !normalizedSections) {
    return null;
  }

  return {
    title: normalizedTitle,
    category: normalizedCategory,
    sections: normalizedSections,
  };
};

const songController = {
  // Seed songs from local songs folder as baseline version 1.0.
  // Existing songs are kept to preserve approved edits.
  seedSongs: async (req, res) => {
    try {
      const songsDir = path.join(__dirname, '..', 'songs');
      const files = fs.readdirSync(songsDir).filter((file) => file.endsWith('.json'));

      const results = [];
      for (const file of files) {
        const filePath = path.join(songsDir, file);
        const songData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
        const { number, title, category, sections } = songData;

        const existingSong = await Song.findByPk(number);
        if (existingSong) {
          results.push({ id: number, created: false, skipped: true });
          continue;
        }

        const normalized = validateSongPayload({ title, category, sections });
        if (!normalized) {
          results.push({ id: number, created: false, skipped: true, reason: 'Invalid payload in file' });
          continue;
        }

        await Song.create({
          id: number,
          title: normalized.title,
          category: normalized.category,
          content: { sections: normalized.sections },
          version: '1.0',
          lastPublishedAt: new Date(),
        });

        await SongDeletion.destroy({ where: { songId: number } });
        results.push({ id: number, created: true });
      }

      res.json({
        message: 'Songs seeded successfully',
        count: results.length,
        created: results.filter((item) => item.created).length,
        skipped: results.filter((item) => item.skipped).length,
        results,
      });
    } catch (error) {
      console.error('Error seeding songs:', error);
      res.status(500).json({ error: error.message });
    }
  },

  // Get all published songs
  getAllSongs: async (req, res) => {
    try {
      const songs = await Song.findAll({
        order: [['id', 'ASC']],
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

  // Sync endpoint used by mobile app (incremental).
  getSyncChanges: async (req, res) => {
    try {
      const now = new Date();
      let sinceDate = null;

      if (req.query.since) {
        sinceDate = new Date(req.query.since);
        if (Number.isNaN(sinceDate.getTime())) {
          return res.status(400).json({ error: 'Invalid since timestamp. Use ISO format.' });
        }
      }

      const songsWhere = sinceDate
        ? { lastPublishedAt: { [Op.gt]: sinceDate } }
        : undefined;
      const deletionsWhere = sinceDate
        ? { deletedAt: { [Op.gt]: sinceDate } }
        : undefined;

      const [songs, deletions, categoryRows] = await Promise.all([
        Song.findAll({
          where: songsWhere,
          order: [['id', 'ASC']],
        }),
        SongDeletion.findAll({
          where: deletionsWhere,
          attributes: ['songId', 'deletedAt', 'lastVersion'],
          order: [['deletedAt', 'ASC']],
        }),
        Song.findAll({
          attributes: ['category'],
          group: ['category'],
          order: [['category', 'ASC']],
        }),
      ]);

      res.json({
        serverTime: now.toISOString(),
        since: sinceDate ? sinceDate.toISOString() : null,
        updates: songs.map(serializeSongForSync),
        deletions: deletions.map((row) => ({
          songId: row.songId,
          deletedAt: row.deletedAt,
          lastVersion: row.lastVersion,
        })),
        categories: categoryRows.map((row) => row.category).filter(Boolean),
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Get recently published song versions
  getRecentUpdates: async (req, res) => {
    try {
      const since = req.query.since
        ? new Date(req.query.since)
        : new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
      if (Number.isNaN(since.getTime())) {
        return res.status(400).json({ error: 'Invalid since timestamp. Use ISO format.' });
      }

      const songs = await Song.findAll({
        where: {
          lastPublishedAt: {
            [Op.gt]: since,
          },
        },
        order: [['lastPublishedAt', 'DESC']],
      });
      res.json(songs);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Editors submit a pending edit request for admin review.
  submitSongChange: async (req, res) => {
    try {
      const payload = validateSongPayload(req.body);
      if (!payload) {
        return res.status(400).json({ error: 'title, category, and sections are required.' });
      }

      const song = await Song.findByPk(req.params.id);
      if (!song) {
        return res.status(404).json({ error: 'Song not found' });
      }

      const change = await SongChange.create({
        songId: song.id,
        baseVersion: song.version,
        proposedTitle: payload.title,
        proposedCategory: payload.category,
        proposedContent: { sections: payload.sections },
        changeNotes: req.body.changeNotes ? String(req.body.changeNotes).trim() : null,
        requestedBy: req.user.id,
      });

      res.status(201).json({
        message: 'Song edit submitted for admin review.',
        change,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Backward-compatible alias for old update endpoint.
  updateSong: async (req, res) => songController.submitSongChange(req, res),

  uploadSongMusic: async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ error: 'Music file is required. Use form field `music`.' });
      }

      const song = await Song.findByPk(req.params.id);
      if (!song) {
        try {
          fs.unlinkSync(req.file.path);
        } catch (_) {
          // No-op
        }
        return res.status(404).json({ error: 'Song not found' });
      }

      const extension = path.extname(req.file.originalname || '') || '.mp3';
      const nextFileName = `${song.id}-${Date.now()}${extension}`;
      const nextFilePath = path.join(MUSIC_UPLOAD_DIR, nextFileName);

      fs.renameSync(req.file.path, nextFilePath);

      const now = new Date();
      const newTrack = {
        fileName: nextFileName,
        originalName: req.file.originalname,
        mimeType: req.file.mimetype || null,
        uploadedAt: now,
      };

      const currentFiles = Array.isArray(song.musicFiles) ? song.musicFiles : [];
      const updatedFiles = [...currentFiles, newTrack];

      await song.update({
        hasMusic: true,
        musicFileName: nextFileName,
        musicMimeType: req.file.mimetype || null,
        musicUpdatedAt: now,
        musicFiles: updatedFiles,
        version: bumpSongVersion(song.version),
        lastPublishedAt: now,
      });

      return res.status(200).json({
        message: 'Music uploaded successfully.',
        song,
      });
    } catch (error) {
      if (req.file?.path) {
        try {
          fs.unlinkSync(req.file.path);
        } catch (_) {
          // No-op
        }
      }
      return res.status(500).json({ error: error.message });
    }
  },

  removeSongMusic: async (req, res) => {
    try {
      const { id } = req.params;
      const { fileName } = req.body;

      if (!fileName) {
        return res.status(400).json({ error: 'File name is required to remove music.' });
      }

      const song = await Song.findByPk(id);
      if (!song) {
        return res.status(404).json({ error: 'Song not found' });
      }

      const currentFiles = Array.isArray(song.musicFiles) ? song.musicFiles : [];
      const fileToRemove = currentFiles.find(f => f.fileName === fileName);

      if (!fileToRemove) {
        return res.status(404).json({ error: 'Music file not found in song records.' });
      }

      const updatedFiles = currentFiles.filter(f => f.fileName !== fileName);

      deleteMusicFile(fileName);

      const now = new Date();
      const hasAnyMusic = updatedFiles.length > 0;

      const updates = {
        musicFiles: updatedFiles,
        hasMusic: hasAnyMusic,
        version: bumpSongVersion(song.version),
        lastPublishedAt: now,
      };

      // Update legacy fields if necessary
      if (song.musicFileName === fileName) {
        if (hasAnyMusic) {
          const lastTrack = updatedFiles[updatedFiles.length - 1];
          updates.musicFileName = lastTrack.fileName;
          updates.musicMimeType = lastTrack.mimeType;
          updates.musicUpdatedAt = lastTrack.uploadedAt;
        } else {
          updates.musicFileName = null;
          updates.musicMimeType = null;
          updates.musicUpdatedAt = null;
        }
      }

      await song.update(updates);

      return res.json({
        message: 'Music removed successfully.',
        song,
      });
    } catch (error) {
      console.error('Error removing music:', error);
      return res.status(500).json({ error: error.message });
    }
  },

  downloadSongMusic: async (req, res) => {
    try {
      const { id } = req.params;
      const { fileName } = req.query;

      const song = await Song.findByPk(id);
      if (!song) {
        return res.status(404).json({ error: 'Song not found.' });
      }

      let selectedFileName = fileName;
      let mimeType = song.musicMimeType;

      if (!selectedFileName) {
        // Default to legacy field or first track
        selectedFileName = song.musicFileName;
        if (!selectedFileName && Array.isArray(song.musicFiles) && song.musicFiles.length > 0) {
          selectedFileName = song.musicFiles[0].fileName;
          mimeType = song.musicFiles[0].mimeType;
        }
      } else {
        // Find mimetype in tracks
        const track = (song.musicFiles || []).find(f => f.fileName === selectedFileName);
        if (track) mimeType = track.mimeType;
      }

      if (!selectedFileName) {
        return res.status(404).json({ error: 'Music not found for this song.' });
      }

      const absolutePath = path.join(MUSIC_UPLOAD_DIR, selectedFileName);
      if (!fs.existsSync(absolutePath)) {
        return res.status(404).json({ error: 'Music file is missing on server.' });
      }

      if (mimeType) {
        res.setHeader('Content-Type', mimeType);
      }
      return res.sendFile(absolutePath);
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  },

  // Admin view for pending/approved/rejected requests.
  getSongChanges: async (req, res) => {
    try {
      const status = req.query.status ? String(req.query.status).toLowerCase() : 'pending';
      const where = {};
      if (['pending', 'approved', 'rejected'].includes(status)) {
        where.status = status;
      }

      const changes = await SongChange.findAll({
        where,
        include: [
          {
            model: Song,
            as: 'song',
            attributes: ['id', 'title', 'category', 'version'],
          },
          {
            model: User,
            as: 'requestedByUser',
            attributes: ['id', 'name', 'email', 'role'],
          },
          {
            model: User,
            as: 'reviewedByUser',
            attributes: ['id', 'name', 'email', 'role'],
          },
        ],
        order: [
          ['status', 'ASC'],
          ['createdAt', 'ASC'],
        ],
      });

      res.json(changes);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Admin review decision: approve applies new version, reject keeps current version.
  reviewSongChange: async (req, res) => {
    const transaction = await Song.sequelize.transaction();
    try {
      const action = String(req.body.action || '').trim().toLowerCase();
      if (!['approve', 'reject'].includes(action)) {
        await transaction.rollback();
        return res.status(400).json({ error: "action must be either 'approve' or 'reject'." });
      }

      const change = await SongChange.findByPk(req.params.changeId, { transaction, lock: transaction.LOCK.UPDATE });
      if (!change) {
        await transaction.rollback();
        return res.status(404).json({ error: 'Song change request not found.' });
      }
      if (change.status !== 'pending') {
        await transaction.rollback();
        return res.status(400).json({ error: 'Song change has already been reviewed.' });
      }

      let publishedSong = null;
      const reviewedAt = new Date();
      const reviewNotes = req.body.reviewNotes ? String(req.body.reviewNotes).trim() : null;

      if (action === 'approve') {
        const song = await Song.findByPk(change.songId, { transaction, lock: transaction.LOCK.UPDATE });
        if (!song) {
          await transaction.rollback();
          return res.status(404).json({ error: 'Song no longer exists.' });
        }

        const nextVersion = bumpSongVersion(song.version);
        await song.update({
          title: change.proposedTitle,
          category: change.proposedCategory,
          content: change.proposedContent,
          version: nextVersion,
          lastPublishedAt: reviewedAt,
        }, { transaction });

        publishedSong = song;

        await SongChange.update({
          status: 'rejected',
          reviewNotes: 'Superseded by a newer approved change.',
          reviewedBy: req.user.id,
          reviewedAt,
        }, {
          where: {
            songId: change.songId,
            status: 'pending',
            id: { [Op.ne]: change.id },
          },
          transaction,
        });

        await SongDeletion.destroy({ where: { songId: change.songId }, transaction });
        change.status = 'approved';
      } else {
        change.status = 'rejected';
      }

      change.reviewNotes = reviewNotes;
      change.reviewedBy = req.user.id;
      change.reviewedAt = reviewedAt;
      await change.save({ transaction });

      await transaction.commit();

      res.json({
        message: action === 'approve' ? 'Song change approved and published.' : 'Song change rejected.',
        change,
        song: publishedSong,
      });
    } catch (error) {
      await transaction.rollback();
      res.status(500).json({ error: error.message });
    }
  },

  // Admin-only hard delete with sync tombstone for mobile clients.
  deleteSong: async (req, res) => {
    const transaction = await Song.sequelize.transaction();
    try {
      const song = await Song.findByPk(req.params.id, { transaction, lock: transaction.LOCK.UPDATE });
      if (!song) {
        await transaction.rollback();
        return res.status(404).json({ error: 'Song not found' });
      }

      await SongChange.update({
        status: 'rejected',
        reviewNotes: 'Song deleted by admin before review.',
        reviewedBy: req.user.id,
        reviewedAt: new Date(),
      }, {
        where: { songId: song.id, status: 'pending' },
        transaction,
      });

      await SongDeletion.upsert({
        songId: song.id,
        deletedBy: req.user.id,
        deletedAt: new Date(),
        lastVersion: song.version,
      }, { transaction });

      const songMusicFileName = song.musicFileName;
      await song.destroy({ transaction });
      await transaction.commit();
      deleteMusicFile(songMusicFileName);

      res.status(204).send();
    } catch (error) {
      await transaction.rollback();
      res.status(500).json({ error: error.message });
    }
  },
};

module.exports = songController;
