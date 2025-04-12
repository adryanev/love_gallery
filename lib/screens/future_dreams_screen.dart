import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:love_gallery/core/models/future_dream.dart';
import 'package:love_gallery/core/repositories/data_repository.dart';
import 'package:love_gallery/core/services/service_locator.dart';
import 'package:love_gallery/core/theme/app_theme.dart';
import 'package:love_gallery/widgets/audio_control.dart';
import 'package:shimmer/shimmer.dart';

class FutureDreamsScreen extends StatefulWidget {
  const FutureDreamsScreen({super.key});

  @override
  State<FutureDreamsScreen> createState() => _FutureDreamsScreenState();
}

class _FutureDreamsScreenState extends State<FutureDreamsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  late Future<List<FutureDream>> _dreamsFuture;
  final DataRepository _repository = getDataRepository();

  @override
  void initState() {
    super.initState();
    _dreamsFuture = _repository.getFutureDreams();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Future Dreams'),
        backgroundColor: AppTheme.petalPink,
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16.0), child: AudioControl()),
        ],
      ),
      backgroundColor: AppTheme.blushPink,
      body: FutureBuilder<List<FutureDream>>(
        future: _dreamsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No dreams found.'));
          }

          final dreams = snapshot.data!;

          return Column(
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Swipe to explore our shared dreams',
                    style: TextStyle(
                      color: AppTheme.dustyMauve,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.swipe, color: AppTheme.dustyMauve, size: 20),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: dreams.length,
                  itemBuilder: (context, index) {
                    final dream = dreams[index];
                    // Calculate distance from current page for parallax effect
                    double distance = (_currentPage - index).abs().toDouble();
                    double scale = 1.0 - (distance * 0.1).clamp(0.0, 0.3);

                    return Transform.scale(
                      scale: scale,
                      child: _buildDreamCard(dream),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  dreams.length,
                  (index) => Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentPage == index
                              ? AppTheme.dustyMauve
                              : AppTheme.petalPink,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDreamCard(FutureDream dream) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.dustyMauve.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: CachedNetworkImage(
              imageUrl: dream.imagePath,
              height: 250,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Shimmer.fromColors(
                    baseColor: AppTheme.blushPink,
                    highlightColor: AppTheme.petalPink,
                    child: Container(height: 250, color: Colors.white),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    height: 250,
                    color: AppTheme.goldWash,
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: AppTheme.blushPink,
                      ),
                    ),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dream.title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 15),
                Text(
                  dream.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
