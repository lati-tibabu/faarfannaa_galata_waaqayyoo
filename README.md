# Faarfannaa Galata Waaqayyoo (Universal Hymn Platform)

![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)
![React](https://img.shields.io/badge/React-19-61DAFB?logo=react)
![Node.js](https://img.shields.io/badge/Node.js-20+-339933?logo=node.js)

**Faarfannaa Galata Waaqayyoo** is a comprehensive digital ecosystem for Afaan Oromoo hymns. It includes a mobile application for believers to access songs, an admin portal for editors to manage the content, and a robust backend to keep everything synchronized.

## Repository Overview

This repository is organized as a monorepo containing three main components:

### 1. [Mobile App](./mobile) (Flutter)
A beautiful, feature-rich mobile application for Android and iOS.
- **Key Features**: Offline access, smart search, favorites, dark mode, and cloud synchronization.
- **Tech**: Flutter, Provider, SQLite (via shared preferences/file storage).

### 2. [Web Admin Portal](./web) (React + Vite)
A modern web interface for managing the hymn database.
- **Key Features**: Song CRUD, change auditing, user management, and admin initialization.
- **Tech**: React 19, Tailwind CSS 4, Radix UI, TanStack Router-compatible logic.

### 3. [Backend API](./backend) (Node.js + Express)
The central hub that powers both the mobile app and the web portal.
- **Key Features**: JWT authentication, song management API, file upload handling, and database change tracking.
- **Tech**: Node.js, Express, Sequelize ORM, PostgreSQL.

---

## Getting Started

### Prerequisites
- [Node.js](https://nodejs.org/) (v20+)
- [Flutter SDK](https://flutter.dev/) (3.10+)
- [PostgreSQL](https://www.postgresql.org/)

### Local Development Setup

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/lati-tibabu/faarfannaa_galata_waaqayyoo.git
   cd faarfannaa_galata_waaqayyoo
   ```

2. **Setup Backend:**
   Navigate to `/backend`, install dependencies, configure your `.env` and run:
   ```bash
   npm run seed  # To initialize the database with songs and admin
   npm run dev
   ```

3. **Setup Admin Portal:**
   Navigate to `/web`, install dependencies and run:
   ```bash
   npm run dev
   ```

4. **Setup Mobile App:**
   Navigate to `/mobile`, install dependencies and run:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://localhost:3000
   ```

## Documentation
For detailed information on each component, please refer to their respective README files:
- [Backend Documentation](./backend/README.md)
- [Web Admin Documentation](./web/README.md)
- [Mobile App Documentation](./mobile/README.md)

---
Developed with ❤️ by **Lati & Dani**
