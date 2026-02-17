const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const DeviceConnection = sequelize.define('DeviceConnection', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  deviceId: {
    type: DataTypes.STRING(128),
    allowNull: false,
    unique: true,
    field: 'device_id',
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: true,
    field: 'user_id',
  },
  userAgent: {
    type: DataTypes.TEXT,
    allowNull: false,
    defaultValue: 'Unknown',
    field: 'user_agent',
  },
  ipAddress: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: 'unknown',
    field: 'ip_address',
  },
  firstSeenAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    field: 'first_seen_at',
  },
  lastSeenAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
    field: 'last_seen_at',
  },
}, {
  tableName: 'device_connections',
});

module.exports = DeviceConnection;
