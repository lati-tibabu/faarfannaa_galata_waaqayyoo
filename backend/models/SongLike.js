const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const SongLike = sequelize.define('SongLike', {
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
}, {
  tableName: 'song_likes',
  indexes: [
    {
      unique: true,
      fields: ['user_id', 'song_id'],
    },
  ],
});

module.exports = SongLike;
