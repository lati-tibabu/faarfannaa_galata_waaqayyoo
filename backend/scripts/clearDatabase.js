require('dotenv').config();

const { sequelize } = require('../models');

const normalizeTableName = (table) => {
  if (typeof table === 'string') {
    return table;
  }

  if (table && typeof table === 'object') {
    if (table.tableName) {
      return table.tableName;
    }
    if (table.name) {
      return table.name;
    }
  }

  return null;
};

const clearDatabase = async () => {
  try {
    await sequelize.authenticate();
    const queryInterface = sequelize.getQueryInterface();
    const tables = await queryInterface.showAllTables();
    const tableNames = tables.map(normalizeTableName).filter(Boolean);

    if (tableNames.length === 0) {
      console.log('No tables found to clear.');
      return;
    }

    await sequelize.query('BEGIN');
    for (const tableName of tableNames) {
      await sequelize.query(`TRUNCATE TABLE "${tableName}" RESTART IDENTITY CASCADE;`);
    }
    await sequelize.query('COMMIT');

    console.log(`Database cleared: ${tableNames.length} table(s) truncated.`);
  } catch (error) {
    await sequelize.query('ROLLBACK').catch(() => {});
    console.error('Failed to clear database:', error.message);
    process.exitCode = 1;
  } finally {
    await sequelize.close();
  }
};

if (require.main === module) {
  clearDatabase();
}

module.exports = clearDatabase;
