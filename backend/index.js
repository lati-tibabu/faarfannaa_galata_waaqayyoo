const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const models = require('./models');
const seedAdmin = require('./scripts/seedAdmin');
const { getGatewayHtml } = require('./utils/htmlTemplates');

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

if (!process.env.JWT_SECRET) {
  console.error('Missing JWT_SECRET in environment. Add JWT_SECRET to backend/.env and restart.');
  process.exit(1);
}

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/users', require('./routes/users'));
app.use('/api/songs', require('./routes/songs'));
app.use('/api/feedback', require('./routes/feedback'));
app.use('/api/visitors', require('./routes/visitors'));
app.use('/api/community', require('./routes/community'));

// Root route
app.get('/', (req, res) => {
  res.send(getGatewayHtml());
});

// Health check route
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Backend is running' });
});

// Sync database and start server (Only if not running on Vercel/serverless)
if (process.env.NODE_ENV !== 'production') {
  models.sequelize.sync({ alter: true }).then(async () => {
    console.log('Database synced successfully');
    await seedAdmin();
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
    });
  }).catch(err => {
    console.error('Unable to sync database:', err);
  });
}

module.exports = app;

