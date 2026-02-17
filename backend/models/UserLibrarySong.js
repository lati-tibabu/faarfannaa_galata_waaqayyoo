const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserLibrarySong = sequelize.define('UserLibrarySong', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'user_id',
  },
  songId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'song_id',
  },
  createdAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
    field: 'created_at',
  },
  updatedAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
    field: 'updated_at',
  },
}, {
  tableName: 'user_library_songs',
  indexes: [
    {
      unique: true,
      fields: ['user_id', 'song_id'],
    },
  ],
});

module.exports = UserLibrarySong;
