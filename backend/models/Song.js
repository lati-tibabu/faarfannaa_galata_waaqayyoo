const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Song = sequelize.define('Song', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: false, // Since ID is provided from mobile
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  category: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  content: {
    type: DataTypes.JSONB, // Store sections as JSON
    allowNull: false,
  },
  version: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: '1.0',
  },
  hasMusic: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: false,
    field: 'has_music',
  },
  musicFileName: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'music_file_name',
  },
  musicMimeType: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'music_mime_type',
  },
  musicUpdatedAt: {
    type: DataTypes.DATE,
    allowNull: true,
    field: 'music_updated_at',
  },
  lastPublishedAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    field: 'last_published_at',
  },
  createdAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  updatedAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'songs',
});

module.exports = Song;
