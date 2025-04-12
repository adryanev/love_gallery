import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:love_gallery/core/services/logging_service.dart';
import 'package:love_gallery/core/services/service_locator.dart';
import 'package:love_gallery/firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;
  static LoggingService? _logger;

  static bool get isInitialized => _initialized;

  static Future<bool> initialize() async {
    try {
      // Try to get the logger if service locator has been initialized
      try {
        if (serviceLocator.isRegistered<LoggingService>()) {
          _logger = serviceLocator<LoggingService>();
        }
      } catch (e) {
        debugPrint('Warning: Logger not available yet in FirebaseService');
      }

      _logInfo('Initializing Firebase');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      _logInfo('Firebase initialized successfully');
      return true;
    } catch (e, stackTrace) {
      _initialized = false;
      _logError('Failed to initialize Firebase', e, stackTrace);
      return false;
    }
  }

  // Helper methods to handle the case where logger might not be available
  static void _logInfo(String message) {
    if (_logger != null) {
      _logger!.i(message);
    } else {
      debugPrint(message);
    }
  }

  static void _logError(String message, dynamic error, StackTrace? stackTrace) {
    if (_logger != null) {
      _logger!.e(message, error, stackTrace);
    } else {
      debugPrint('$message: $error');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}
