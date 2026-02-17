const { AnonymousFeedback } = require('../models');

const ALLOWED_CATEGORIES = new Set(['general', 'ui', 'bug', 'feature', 'music', 'lyrics']);

const normalizeCategory = (value = 'general') => {
  const category = String(value).trim().toLowerCase();
  return ALLOWED_CATEGORIES.has(category) ? category : 'general';
};

const parseRating = (value) => {
  if (value === undefined || value === null || value === '') {
    return null;
  }

  const rating = Number(value);
  if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
    return null;
  }

  return rating;
};

const feedbackController = {
  submitAnonymousFeedback: async (req, res) => {
    try {
      const message = String(req.body?.message || '').trim();
      if (message.length < 5) {
        return res.status(400).json({ error: 'Feedback message must be at least 5 characters.' });
      }

      const category = normalizeCategory(req.body?.category);
      const rating = parseRating(req.body?.rating);
      const page = req.body?.page ? String(req.body.page).slice(0, 120) : null;

      const feedback = await AnonymousFeedback.create({
        message,
        category,
        rating,
        page,
        source: 'web',
        ipAddress: req.ip,
        userAgent: req.get('user-agent') || null,
      });

      res.status(201).json({
        message: 'Feedback submitted successfully.',
        feedbackId: feedback.id,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  getAllFeedback: async (req, res) => {
    try {
      const status = req.query?.status ? String(req.query.status).trim().toLowerCase() : null;
      const where = status && ['new', 'reviewed'].includes(status) ? { status } : {};

      const rows = await AnonymousFeedback.findAll({
        where,
        order: [['createdAt', 'DESC']],
      });
      res.json(rows);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  markFeedbackReviewed: async (req, res) => {
    try {
      const item = await AnonymousFeedback.findByPk(req.params.id);
      if (!item) {
        return res.status(404).json({ error: 'Feedback not found.' });
      }

      item.status = 'reviewed';
      await item.save();

      res.json({
        message: 'Feedback marked as reviewed.',
        feedback: item,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },
};

module.exports = feedbackController;
