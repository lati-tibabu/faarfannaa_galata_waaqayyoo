# Faarfannaa Galata Waaqayyoo Admin Portal

This is the web-based admin portal for the Faarfannaa Galata Waaqayyoo project. It allows administrators and editors to manage hymns, track changes, and monitor users.

## Tech Stack

- **Framework**: [React 19](https://react.dev/)
- **Build Tool**: [Vite](https://vite.dev/)
- **Styling**: [Tailwind CSS 4](https://tailwindcss.com/)
- **UI Components**: [Radix UI](https://www.radix-ui.com/) & [Lucide React](https://lucide.dev/)
- **State/Routing**: [React Router 7](https://reactrouter.com/)
- **HTTP Client**: [Axios](https://axios-http.com/)

## Features

- **Dashboard**: Overview of system status and quick stats.
- **Hymn Management**: Full CRUD operations for the song database.
- **Change Tracking**: View and manage historical changes to individual songs.
- **User Management**: View and manage registered users.
- **Admin Setup**: Special first-time login setup for initializing the administrator account.
- **Responsive Design**: Optimized for desktop and mobile browsers.

## Project Structure

- `src/pages/`: Main application views (Dashboard, Login, Song List, etc.)
- `src/components/`: Reusable UI components.
- `src/services/`: API integration services using Axios.
- `src/lib/`: Utility functions and shared libraries.

## Setup & Run

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configuration:**
   - Update `src/services/api.js` (or environment variables) with the backend API URL.

3. **Development Mode:**
   ```bash
   npm run dev
   ```

4. **Build for Production:**
   ```bash
   npm run build
   ```

## Contributing
Please follow the coding standards and use the provided components for UI consistency.
