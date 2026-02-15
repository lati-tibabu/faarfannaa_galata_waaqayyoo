# Faarfannaa Galata Waaqayyoo Backend

This is the backend application for the Faarfannaa Galata Waaqayyoo app, built with Node.js, Express, and Sequelize ORM with PostgreSQL.

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up PostgreSQL database and update `.env` file with your database credentials.

3. Run the application:
   ```bash
   npm start
   ```

   For development with auto-restart:
   ```bash
   npm run dev
   ```

## API Endpoints

- `GET /health` - Health check
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create a new user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

## Environment Variables

- `NODE_ENV` - Environment (development/production)
- `PORT` - Server port (default: 3000)
- `DB_HOST` - Database host
- `DB_PORT` - Database port
- `DB_NAME` - Database name
- `DB_USER` - Database username
- `DB_PASSWORD` - Database password