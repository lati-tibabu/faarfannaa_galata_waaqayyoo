const { VisitorAccount } = require('../models');

const visitorController = {
  createVisitor: async (req, res) => {
    try {
      const username = String(req.body?.username || req.body?.displayName || '').trim();
      if (username.length < 2) {
        return res.status(400).json({ error: 'Username must be at least 2 characters.' });
      }

      const visitor = await VisitorAccount.create({
        displayName: username.slice(0, 60),
        deviceId: req.header('X-Device-Id') || null,
      });

      return res.status(201).json({
        visitor: {
          id: visitor.id,
          username: visitor.displayName,
          displayName: visitor.displayName,
          createdAt: visitor.createdAt,
        },
      });
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  },
};

module.exports = visitorController;
