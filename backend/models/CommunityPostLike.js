const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const CommunityPostLike = sequelize.define('CommunityPostLike', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  postId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'post_id',
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'user_id',
  },
}, {
  tableName: 'community_post_likes',
  indexes: [
    {
      unique: true,
      fields: ['post_id', 'user_id'],
    },
  ],
});

module.exports = CommunityPostLike;
