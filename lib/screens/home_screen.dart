import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:love_gallery/core/models/memory.dart';
import 'package:love_gallery/core/models/future_dream.dart';
import 'package:love_gallery/core/theme/app_theme.dart';
import 'package:love_gallery/core/theme/screen_utils.dart';
import 'package:love_gallery/screens/doodle_screen.dart';
import 'package:love_gallery/screens/future_dreams_screen.dart';
import 'package:love_gallery/screens/gallery_screen.dart';
import 'package:love_gallery/screens/settings_screen.dart';
import 'package:love_gallery/screens/whisper_screen.dart';
import 'package:love_gallery/services/audio_service.dart';
import 'package:love_gallery/widgets/audio_control.dart';
import 'package:love_gallery/core/repositories/data_repository.dart';
import 'package:love_gallery/core/services/service_locator.dart';
import 'package:love_gallery/core/services/logging_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _dataFuture;
  final AudioService _audioService = AudioService();
  final DataRepository _repository = getDataRepository();
  late final LoggingService _logger;

  @override
  void initState() {
    super.initState();
    _logger = getLogger();
    _logger.i('HomeScreen initialized');
    _loadData();
    _initializeBackgroundMusic();
  }

  void _loadData() {
    _logger.d('Loading home screen data');
    _dataFuture = Future.wait([
      _repository.getMemories(),
      _repository.getFutureDreams(),
    ]);
  }

  Future<void> _initializeBackgroundMusic() async {
    try {
      _logger.d('Initializing background music');

      // Check if audio is already initialized to avoid duplicate initialization
      bool audioInitialized = false;
      try {
        // Initialize the audio service first with a timeout to prevent hanging
        await _audioService.initialize().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            _logger.w('Audio initialization timed out');
            throw Exception('Audio initialization timed out');
          },
        );
        audioInitialized = true;
        _logger.d('Audio service initialized successfully');
      } catch (initError, initStack) {
        _logger.e('Error during audio initialization', initError, initStack);
        // Continue even if initialization fails
      }

      if (audioInitialized) {
        // Then play the music
        await _audioService.play();
        _logger.d('Background music started successfully');
      } else {
        _logger.w(
          'Skipped playing background music due to initialization failure',
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error starting background music: ${e.toString()}',
        e,
        stackTrace,
      );
      // No retry for Android to prevent crash loops
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = 1.sw;
    _logger.v('Building HomeScreen with width: $screenWidth');

    return Scaffold(
      backgroundColor: AppTheme.blushPink,
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            _logger.d('HomeScreen data still loading');
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            _logger.e(
              'Error loading HomeScreen data',
              snapshot.error,
              snapshot.stackTrace,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            _logger.w('No data found for HomeScreen');
            return const Center(child: Text('No data found.'));
          }

          final memories = snapshot.data![0] as List<Memory>;
          final dreams = snapshot.data![1] as List<FutureDream>;
          _logger.d(
            'HomeScreen data loaded: ${memories.length} memories, ${dreams.length} dreams',
          );

          return Stack(
            children: [
              // Watercolor background with hearts
              Positioned.fill(child: _buildWatercolorBackground(context)),

              // Main content
              SafeArea(
                child: SingleChildScrollView(
                  padding: Responsive.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Responsive.h(20)),

                      // App Title
                      Center(
                        child: Text(
                          'LOVE GALLERY',
                          style: TextStyle(
                            fontSize: Responsive.sp(32),
                            color: AppTheme.warmCharcoal,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      SizedBox(height: Responsive.h(20)),

                      // Welcome Banner
                      _buildWelcomeBanner(context),

                      SizedBox(height: Responsive.h(30)),

                      // Memory Gallery Section
                      _buildSectionTitle(context, 'Memory Gallery'),
                      SizedBox(height: Responsive.h(10)),
                      _buildMemoryGalleryPreview(
                        context,
                        memories,
                        screenWidth,
                      ),

                      SizedBox(height: Responsive.h(30)),

                      // Whisper Corner Section
                      _buildSectionTitle(context, 'Whisper Corner'),
                      SizedBox(height: Responsive.h(10)),
                      _buildWhisperCorner(context),

                      SizedBox(height: Responsive.h(30)),

                      // Row for Future Us and Doodle
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Future Us Section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(context, 'Future Us'),
                                SizedBox(height: Responsive.h(10)),
                                if (dreams.isNotEmpty)
                                  _buildFutureUsPreview(context, dreams.first),
                              ],
                            ),
                          ),

                          SizedBox(width: Responsive.w(20)),

                          // Doodle Section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(context, 'Doodle Love'),
                                SizedBox(height: Responsive.h(10)),
                                _buildDoodlePreview(context),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: Responsive.h(30)),
                    ],
                  ),
                ),
              ),

              // Settings button
              Positioned(
                top: Responsive.h(40),
                right: Responsive.w(20),
                child: IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: AppTheme.warmCharcoal.withValues(alpha: 0.6),
                    size: Responsive.r(28),
                  ),
                  onPressed: () {
                    _logger.d('Navigating to SettingsScreen');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ),

              // Audio control button
              Positioned(
                top: Responsive.h(40),
                left: Responsive.w(20),
                child: const AudioControl(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWatercolorBackground(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background texture
        Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.1, -0.3),
              radius: 1.2,
              colors: [
                Colors.white.withValues(alpha: 0.8),
                AppTheme.blushPink.withValues(alpha: 0.6),
                AppTheme.petalPink.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),

        // Random hearts scattered around
        ...List.generate(12, (index) {
          final random = index / 12;
          final heartSize = Responsive.r(10.0 + (index % 3) * 10.0);
          final opacity = 0.1 + (random * 0.2);
          final posX = MediaQuery.of(context).size.width * random * 0.9;
          final posY =
              MediaQuery.of(context).size.height * (0.1 + random * 0.7);

          return Positioned(
            left: posX,
            top: posY,
            child: Opacity(
              opacity: opacity,
              child: Icon(
                Icons.favorite,
                color: AppTheme.roseQuartz,
                size: heartSize,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GalleryScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: Responsive.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.petalPink.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(Responsive.r(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Welcome to the\nGallery of Us',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Responsive.sp(28),
              color: AppTheme.warmCharcoal,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: Responsive.sp(24),
        color: AppTheme.warmCharcoal,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMemoryGalleryPreview(
    BuildContext context,
    List<Memory> memories,
    double screenWidth,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GalleryScreen()),
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: (screenWidth - 60.w) / 3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              memories.take(3).map((memory) {
                // Calculate width accounting for spacing between items
                final itemWidth = (screenWidth - 60.w - 16.w) / 3;

                // Get the path from the first media item if available
                final String imagePath =
                    memory.mediaItems.isNotEmpty
                        ? memory.mediaItems.first.path
                        : 'assets/animations/placeholder.png';

                return _buildFramedImage(
                  context,
                  imagePath,
                  itemWidth,
                  itemWidth, // Square shape
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildWhisperCorner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WhisperScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.petalPink.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volume_up, color: AppTheme.warmCharcoal, size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFutureUsPreview(BuildContext context, FutureDream dream) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FutureDreamsScreen()),
        );
      },
      child: _buildFramedImage(context, dream.imagePath, double.infinity, 180),
    );
  }

  Widget _buildDoodlePreview(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DoodleScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.goldWash, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.brush,
            color: AppTheme.dustyMauve.withValues(alpha: 0.5),
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildFramedImage(
    BuildContext context,
    String imagePath,
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.goldWash.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.goldWash, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: imagePath,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildShimmerPlaceholder(),
          errorWidget: (context, url, error) {
            // If image fails to load, show a placeholder with watercolor style
            return Container(
              color: AppTheme.petalPink.withValues(alpha: 0.5),
              child: Center(
                child: Icon(
                  Icons.image,
                  color: AppTheme.dustyMauve.withValues(alpha: 0.7),
                  size: 30,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Builder(
      builder:
          (context) => Shimmer.fromColors(
            baseColor: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.3),
            highlightColor: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.1),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
            ),
          ),
    );
  }
}
