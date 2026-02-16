# Faarfannaa Galata Waaqayyoo Backend

This is the backend application for the Faarfannaa Galata Waaqayyoo app, built with Node.js, Express, and Sequelize ORM with PostgreSQL. It provides a RESTful API for managing users, songs, and synchronizing data with mobile and web clients.

## Project Structure

- `index.js`: Entry point of the application.
- `config/`: Configuration files (e.g., database connection).
- `controllers/`: Request handlers for different routes.
- `middleware/`: Custom middleware (auth, roles, etc.).
- `models/`: Sequelize models for database tables.
- `routes/`: Express route definitions.
- `scripts/`: Utility scripts for database management and seeding.
- `services/`: Business logic and external service integrations.
- `songs/`: Initial song data in JSON format for seeding.

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Database Configuration:**
   - Create a PostgreSQL database.
   - Copy `.env.example` to `.env` and update the database credentials and other environment variables.

3. **Run the application:**
   - Production: `npm start`
   - Development: `npm run dev` (uses nodemon)

4. **Initialize Database:**
   - Run universal seed (songs + admin): `npm run seed`
   - Default admin login is `admin` / `admin`.

5. **Utility Commands:**
   - Clear database: `npm run db:clear`
   - Reset database: `npm run db:reset`

## Features

- **Authentication & Authorization**: JWT-based auth with role-based access control (Admin, User).
- **Song Management**: CRUD operations for hymns.
- **Change Tracking**: Tracks song modifications and deletions for client synchronization.
- **Music Uploads**: Supports uploading and streaming music files for hymns.
- **Device Tracking**: Keeps track of connected devices.

## API Endpoints

### Auth & Users
- `POST /api/users/login` - User login
- `POST /api/users/register` - User registration
- `GET /api/users` - Get all users (Admin only)
- `GET /api/users/:id` - Get user by ID

### Songs
- `GET /api/songs` - List all songs
- `GET /api/songs/:id` - Get song details
- `POST /api/songs` - Create song (Admin only)
- `PUT /api/songs/:id` - Update song (Admin only)
- `DELETE /api/songs/:id` - Delete song (Admin only)
- `POST /api/songs/:id/music` - Upload music file
- `GET /api/songs/:id/music` - Stream music file

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | 3000 |
| `DB_HOST` | Database host | localhost |
| `DB_USER` | Database user | postgres |
| `DB_PASSWORD` | Database password | - |
| `DB_NAME` | Database name | faarfannaa |
| `JWT_SECRET` | JWT signing secret | - |
| `ADMIN_EMAIL` | Seeded admin email | admin |
| `ADMIN_PASSWORD`| Seeded admin password | admin |

