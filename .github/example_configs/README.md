# Firebase Configuration Examples

This directory contains example configuration files for Firebase integration with placeholders instead of actual API keys and sensitive values.

## Setup Instructions

1. Copy these example files to their respective locations in the project:
   - `google-services.json.example` → `android/app/google-services.json`
   - `GoogleService-Info.plist.example` → `ios/Runner/GoogleService-Info.plist`
   - `firebase_options.dart.example` → `lib/firebase_options.dart`
   - `firebase.json.example` → `firebase.json`

2. Replace the placeholder values with your actual Firebase configuration values:
   - `YOUR-ANDROID-API-KEY` - Your Android Firebase API key
   - `YOUR-IOS-API-KEY` - Your iOS Firebase API key
   - `your-project-id` - Your Firebase project ID
   - `000000000000` - Your Firebase project number and other numeric IDs

## Security Notes

- Never commit the actual configuration files with real API keys to a public repository
- These files are already added to `.gitignore` to prevent accidental commits
- Each developer should obtain their own Firebase configuration files and follow these setup instructions