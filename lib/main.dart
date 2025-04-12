import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:love_gallery/core/theme/app_theme.dart';
import 'package:love_gallery/screens/home_screen.dart';
import 'package:love_gallery/core/services/firebase_service.dart';
import 'package:love_gallery/core/services/service_locator.dart';
import 'package:love_gallery/services/audio_service.dart';

// This is to handle missing assets during development
class ImageUtils {
  static Widget getPlaceholderImage(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    final color =
        path.contains('memory')
            ? AppTheme.roseQuartz
            : path.contains('dream')
            ? AppTheme.goldWash
            : AppTheme.petalPink;

    return Image.asset(
      'assets/images/placeholder.jpg',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: color.withValues(alpha: 0.3),
          child: Center(child: Icon(Icons.image, color: color, size: 40)),
        );
      },
    );
  }
}

Future<void> main() async {
  // Wrap everything in a try-catch to prevent app crashes during initialization
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Setup core services first
    setupCoreServices();
    final logger = getLogger();

    logger.i('Application starting');

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    logger.d('Device orientation set to portrait only');

    // Try to initialize Firebase, but continue if it fails
    bool firebaseInitialized = false;
    logger.d('Attempting to initialize Firebase');
    await FirebaseService.initialize()
        .then((initialized) {
          firebaseInitialized = initialized;
          if (initialized) {
            logger.i('Firebase initialized successfully');
          } else {
            logger.w('Firebase initialization failed, using local data');
          }
        })
        .catchError((error, stackTrace) {
          logger.e('Error during Firebase initialization', error, stackTrace);
          // Continue with local data
        });

    // Setup repositories with the appropriate type
    logger.d(
      'Setting up repositories with ${firebaseInitialized ? 'Firebase' : 'mock'} data repository',
    );
    setupRepositories(useMock: !firebaseInitialized);
    logger.i('Service locator setup complete');

    // We don't initialize audio here anymore - it will be done in HomeScreen
    // to allow better error handling

    logger.i('Starting application');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    // Last resort error handling to prevent crashes
    debugPrint('Critical error during app initialization: $e');
    debugPrint(stackTrace.toString());

    // Still try to launch the app even if initialization failed
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'The app encountered an error during startup. Some features may not work properly.\n\nDetails: $e',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = getLogger();
    logger.d('Building main application widget');

    return ScreenUtilInit(
      designSize: const Size(
        360,
        800,
      ), // Design size based on common mobile dimensions
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        logger.d('ScreenUtil initialized with design size: 360x800');
        return MaterialApp(
          title: 'Love Gallery',
          theme: AppTheme.getLightTheme(),
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        );
      },
    );
  }
}
