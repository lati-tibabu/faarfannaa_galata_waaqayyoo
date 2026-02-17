const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const AnonymousFeedback = sequelize.define('AnonymousFeedback', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  message: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  category: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: 'general',
  },
  rating: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  page: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  status: {
    type: DataTypes.ENUM('new', 'reviewed'),
    allowNull: false,
    defaultValue: 'new',
  },
  source: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: 'web',
  },
  ipAddress: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'ip_address',
  },
  userAgent: {
    type: DataTypes.TEXT,
    allowNull: true,
    field: 'user_agent',
  },
}, {
  tableName: 'anonymous_feedback',
});

module.exports = AnonymousFeedback;
