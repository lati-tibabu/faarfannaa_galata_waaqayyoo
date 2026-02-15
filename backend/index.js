const express = require('express');
const dotenv = require('dotenv');
const models = require('./models');
const seedAdmin = require('./scripts/seedAdmin');

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/users', require('./routes/users'));
app.use('/api/songs', require('./routes/songs'));

// Health check route
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Backend is running' });
});

// Sync database and start server
models.sequelize.sync({ alter: true }).then(async () => {
  console.log('Database synced successfully');
  await seedAdmin();
  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
}).catch(err => {
  console.error('Unable to sync database:', err);
});