# 💖 Love Gallery

A heartfelt, interactive mobile experience created as a special birthday gift. This Flutter application celebrates a romantic relationship through art, love notes, voice messages, and shared memories.

## 🌟 Features

- **Home Screen** - Beautiful welcome screen with animations and background music
- **Memory Gallery** - Collection of shared memories with text and images
- **Whisper Corner** - Intimate voice messages with beautiful animations
- **Future Dreams** - Interactive cards showing your shared aspirations
- **Doodle Page** - Draw and create art together
- **Settings** - Control music and privacy options

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone this repository:
   ```
   git clone <repository-url>
   ```

2. Navigate to the project folder:
   ```
   cd my_love
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## 🎨 Customization

### Assets

- Replace placeholder images in `assets/images/` with your own photos
- Replace audio files in `assets/audio/` with your own recordings
- Edit mock data in `lib/core/data/mock_data.dart` to update content

### Personalization

1. Modify the memories, whispers, and future dreams in `mock_data.dart`
2. Replace placeholder images with meaningful photos
3. Record your own voice messages and place them in the audio folder
4. Adjust colors and styling in `lib/core/theme/app_theme.dart` if desired

## 📱 Supported Platforms

- Android
- iOS

## 🔒 Privacy

This app is designed for personal use and doesn't collect or transmit any data. All content is stored locally on the device.

## 💝 Note

This app was created with love as a special gift. Each screen, animation, and interaction was designed to evoke emotion and celebrate your unique relationship.

Happy Birthday! 🎂

## Firebase Integration

The app supports both local data (JSON files in assets) and Firebase integration for cloud storage and database. The implementation includes:

1. **Data Models**:
   - Memory: Photos and details of special moments
   - Whisper: Audio messages and their transcripts
   - Future Dream: Future plans and wishes

2. **Firebase Services**:
   - Firestore Database: For storing structured data
   - Firebase Storage: For storing media files (images and audio)

3. **Migration Capabilities**:
   - Admin screen to migrate local data to Firebase
   - Option to migrate specific data types or all data at once

4. **Fallback Mechanism**:
   - App works with local data if Firebase is not initialized
   - Seamless switching between cloud and local data sources

## Setting Up Firebase

1. Create a Firebase project at [firebase.google.com](https://firebase.google.com)
2. Run the following command to configure Firebase for your app:
   ```
   flutter pub global activate flutterfire_cli
   flutterfire configure
   ```
3. The above command will generate Firebase configuration files
4. Once Firebase is configured, you can use the Migration screen in Settings to upload local data to Firebase

## Folder Structure

- `lib/core/models`: Data models
- `lib/core/repositories`: Firebase and Firestore repositories
- `lib/core/services`: Firebase services
- `lib/core/data`: Data handling including MockData
- `lib/core/tools`: Migration utilities
- `lib/screens/admin`: Admin screens including data migration

## Dependencies

- Firebase Core, Firestore, Storage, and Auth
- Flutter standard libraries

## 🔐 Sensitive Information for Contributors

For security reasons, sensitive Firebase configuration files are not included in the public repository. If you're contributing to this project, you'll need to set up your own Firebase environment:

1. Example configuration files are provided in `.github/example_configs/` directory
2. Copy these example files to their correct locations and replace placeholders with your actual Firebase credentials
3. The following files contain sensitive data and are excluded from git:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `lib/firebase_options.dart`
   - `firebase.json`

**Never commit these files with real API keys to the public repository!**
