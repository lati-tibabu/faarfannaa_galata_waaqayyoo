const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const CommunityPost = sequelize.define('CommunityPost', {
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
  content: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  imageUrl: {
    type: DataTypes.TEXT,
    allowNull: true,
    field: 'image_url',
  },
}, {
  tableName: 'community_posts',
});

module.exports = CommunityPost;
