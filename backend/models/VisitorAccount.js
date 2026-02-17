const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const VisitorAccount = sequelize.define('VisitorAccount', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  displayName: {
    type: DataTypes.STRING,
    allowNull: false,
    field: 'display_name',
  },
  deviceId: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'device_id',
  },
}, {
  tableName: 'visitor_accounts',
});

module.exports = VisitorAccount;
