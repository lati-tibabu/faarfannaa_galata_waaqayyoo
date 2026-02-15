const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const SongDeletion = sequelize.define('SongDeletion', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  songId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    unique: true,
    field: 'song_id',
  },
  deletedBy: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'deleted_by',
  },
  deletedAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    field: 'deleted_at',
  },
  lastVersion: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: '1.0',
    field: 'last_version',
  },
}, {
  tableName: 'song_deletions',
});

module.exports = SongDeletion;
