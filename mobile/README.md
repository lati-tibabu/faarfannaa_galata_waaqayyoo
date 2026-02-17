# Faarfannaa Galata Waaqayyoo

![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)

**Faarfannaa Galata Waaqayyoo** (Praise Songs of God) is a spiritually enriching mobile application designed for browsing, reading, and meditating on hymns in the Oromo language. Featuring a comprehensive collection of traditional "Faarfannaa", the app offers an intuitive interface with robust tools for navigation, search, and personal customization.

## Features

- **📖 Extensive Hymn Collection**: Browse a library of 300+ hymns organized by categories.
- **🔄 Live Synchronization**: Automatically syncs with the backend to receive song updates and deletions.
- **🔍 Smart Search**: Quickly find songs by title, hymn number, or content.
- **❤️ Favorites**: Mark hymns as favorites for quick access.
- **📂 Categorized Views**: Explore songs grouped by themes or occasions.
- **🌓 Dark & Light Mode**: Seamlessly switch between light and dark themes for comfortable reading.
- **📱 Responsive UI**: Optimized for both Android and iOS devices using Flutter.

## Project Structure

```
lib/
├── main.dart           # Entry point & App configuration
├── theme.dart          # App Theme definition (Material 3)
├── models/             # Data models (Hymn, Category, Reports)
├── providers/          # State management (ChangeNotifier/Provider)
├── screens/            # UI Screens (Home, Explore, Detail, Settings)
├── services/           # Logic services (SongService, API Sync, Persistence)
└── l10n/               # Localization strings (Oromo/English)
assets/
└── songs/              # Bundled JSON data files for offline access
```

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10+).
- An IDE (VS Code or Android Studio) with Flutter & Dart extensions.
- [Git](https://git-scm.com/) installed.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/lati-tibabu/faarfannaa_galata_waaqayyoo.git
   cd faarfannaa_galata_waaqayyoo/mobile
   ```

2. **Install dependencies:**
    ```bash
    flutter pub get
    ```

3. **Configure API (Optional):**
    For synchronization features, provide the backend URL during run/build:
    ```bash
    flutter run --dart-define=API_BASE_URL=https://your-api.com
    ```

4. **Run the application:**
    ```bash
    flutter run
    ```


## Contributing

Contributions are welcome! If you have suggestions or improvements, please fork the repository and create a pull request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the GNU General Public License v3. See `LICENSE` for more information.

---
Developed by **Lati & Dani**
