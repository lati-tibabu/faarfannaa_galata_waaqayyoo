const { Sequelize } = require('sequelize');
const sequelize = require('../config/database');

// Import models
const User = require('./User');
const Song = require('./Song');

// Initialize models
const models = {
  User,
  Song,
};

// Run associations if any
Object.keys(models).forEach(modelName => {
  if (models[modelName].associate) {
    models[modelName].associate(models);
  }
});

models.sequelize = sequelize;
models.Sequelize = Sequelize;

module.exports = models;