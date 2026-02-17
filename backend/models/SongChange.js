const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const SongChange = sequelize.define('SongChange', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  songId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'song_id',
  },
  baseVersion: {
    type: DataTypes.STRING,
    allowNull: false,
    field: 'base_version',
  },
  proposedTitle: {
    type: DataTypes.STRING,
    allowNull: false,
    field: 'proposed_title',
  },
  proposedCategory: {
    type: DataTypes.STRING,
    allowNull: false,
    field: 'proposed_category',
  },
  proposedContent: {
    type: DataTypes.JSONB,
    allowNull: false,
    field: 'proposed_content',
  },
  changeNotes: {
    type: DataTypes.TEXT,
    allowNull: true,
    field: 'change_notes',
  },
  status: {
    type: DataTypes.ENUM('pending', 'approved', 'rejected'),
    allowNull: false,
    defaultValue: 'pending',
  },
  reviewNotes: {
    type: DataTypes.TEXT,
    allowNull: true,
    field: 'review_notes',
  },
  requestedBy: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'requested_by',
  },
  reviewedBy: {
    type: DataTypes.INTEGER,
    allowNull: true,
    field: 'reviewed_by',
  },
  reviewedAt: {
    type: DataTypes.DATE,
    allowNull: true,
    field: 'reviewed_at',
  },
}, {
  tableName: 'song_changes',
});

module.exports = SongChange;
