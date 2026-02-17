const { Sequelize } = require('sequelize');
const sequelize = require('../config/database');

// Import models
const User = require('./User');
const Song = require('./Song');
const DeviceConnection = require('./DeviceConnection');
const SongChange = require('./SongChange');
const SongDeletion = require('./SongDeletion');
const UserLibrarySong = require('./UserLibrarySong');

// Initialize models
const models = {
  User,
  Song,
  DeviceConnection,
  SongChange,
  SongDeletion,
  UserLibrarySong,
};

User.hasMany(DeviceConnection, { foreignKey: 'userId', as: 'deviceConnections' });
DeviceConnection.belongsTo(User, { foreignKey: 'userId', as: 'user' });

Song.hasMany(SongChange, { foreignKey: 'songId', as: 'changes' });
SongChange.belongsTo(Song, { foreignKey: 'songId', as: 'song' });

User.hasMany(SongChange, { foreignKey: 'requestedBy', as: 'requestedSongChanges' });
User.hasMany(SongChange, { foreignKey: 'reviewedBy', as: 'reviewedSongChanges' });
SongChange.belongsTo(User, { foreignKey: 'requestedBy', as: 'requestedByUser' });
SongChange.belongsTo(User, { foreignKey: 'reviewedBy', as: 'reviewedByUser' });

User.belongsToMany(Song, {
  through: UserLibrarySong,
  foreignKey: 'userId',
  otherKey: 'songId',
  as: 'librarySongs',
});
Song.belongsToMany(User, {
  through: UserLibrarySong,
  foreignKey: 'songId',
  otherKey: 'userId',
  as: 'savedByUsers',
});
User.hasMany(UserLibrarySong, { foreignKey: 'userId', as: 'libraryEntries' });
Song.hasMany(UserLibrarySong, { foreignKey: 'songId', as: 'libraryEntries' });
UserLibrarySong.belongsTo(User, { foreignKey: 'userId', as: 'user' });
UserLibrarySong.belongsTo(Song, { foreignKey: 'songId', as: 'song' });

// Run associations if any
Object.keys(models).forEach(modelName => {
  if (models[modelName].associate) {
    models[modelName].associate(models);
  }
});

models.sequelize = sequelize;
models.Sequelize = Sequelize;

module.exports = models;
