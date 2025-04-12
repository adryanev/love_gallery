import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:love_gallery/core/models/memory.dart';
import 'package:love_gallery/core/theme/app_theme.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:chewie/chewie.dart';
import 'dart:async';

class MemoryDetailScreen extends StatelessWidget {
  final Memory memory;

  const MemoryDetailScreen({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(memory.title),
        backgroundColor: AppTheme.petalPink,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMediaGallery(context),
            _buildContent(context),
            if (memory.url != null && memory.url!.isNotEmpty)
              _buildLinkButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGallery(BuildContext context) {
    if (memory.mediaItems.isEmpty) {
      return Container(
        height: 250,
        color: AppTheme.roseQuartz,
        child: const Center(
          child: Icon(Icons.image, size: 80, color: Colors.white),
        ),
      );
    }

    return MediaGalleryWithIndicators(
      mediaItems: memory.mediaItems,
      memory: memory,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(memory.title, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Date: ${_formatDate(memory.date)}',
            style: TextStyle(
              color: AppTheme.dustyMauve,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            memory.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Link', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _launchURL(memory.url!),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.goldWash.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.goldWash, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      memory.url!,
                      style: TextStyle(
                        color: AppTheme.dustyMauve,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.open_in_new, size: 18, color: AppTheme.dustyMauve),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }
}

class MediaGalleryWithIndicators extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final Memory memory;

  const MediaGalleryWithIndicators({
    super.key,
    required this.mediaItems,
    required this.memory,
  });

  @override
  State<MediaGalleryWithIndicators> createState() =>
      _MediaGalleryWithIndicatorsState();
}

class _MediaGalleryWithIndicatorsState
    extends State<MediaGalleryWithIndicators> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _mediaPrefetched = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_mediaPrefetched) {
      _prefetchImages();
      _mediaPrefetched = true;
    }
  }

  void _prefetchImages() {
    // Prefetch images (needs context) - called from didChangeDependencies
    for (final mediaItem in widget.mediaItems) {
      if (mediaItem.type == MediaType.image) {
        precacheImage(CachedNetworkImageProvider(mediaItem.path), context);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 270.w,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaItems.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final mediaItem = widget.mediaItems[index];
              return mediaItem.type == MediaType.image
                  ? _buildImageItem(mediaItem, index)
                  : _buildVideoItem(mediaItem, index);
            },
          ),
        ),
        if (widget.mediaItems.length > 1) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.mediaItems.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentPage == index
                            ? AppTheme.petalPink
                            : AppTheme.dustyMauve.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.swipe, size: 16, color: AppTheme.dustyMauve),
                const SizedBox(width: 4),
                Text(
                  'Swipe to see more',
                  style: TextStyle(color: AppTheme.dustyMauve, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageItem(MediaItem mediaItem, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => FullScreenImageViewer(
                  imageUrl: mediaItem.path,
                  tag: 'memory-${widget.memory.id}-$index',
                ),
          ),
        );
      },
      child: Hero(
        tag: 'memory-${widget.memory.id}-$index',
        child: CachedNetworkImage(
          imageUrl: mediaItem.path,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildShimmerPlaceholder(),
          errorWidget: (context, url, error) {
            return Container(
              color: AppTheme.roseQuartz,
              child: Center(
                child: Icon(Icons.image, size: 80.w, color: Colors.white),
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

  // Helper to check if format might be problematic
  bool _hasUnsupportedFormat(String url) {
    final lowercaseUrl = url.toLowerCase();
    // .mov files are particularly problematic on some platforms
    return lowercaseUrl.endsWith('.mov');
  }

  Widget _buildVideoItem(MediaItem mediaItem, int index) {
    // Handle potentially unsupported formats specially
    if (_hasUnsupportedFormat(mediaItem.path)) {
      return Container(
        color: AppTheme.roseQuartz,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50.w, color: Colors.white),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'Video format may not be supported on this device',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(mediaItem.path);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in browser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.dustyMauve,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Directly load video when needed (no prefetching)
    return EnhancedVideoPlayerWidget(
      videoPath: mediaItem.path,
      onError: (error) {
        // Handle video error in UI
        debugPrint('Error playing video: $error');
      },
    );
  }
}

class EnhancedVideoPlayerWidget extends StatefulWidget {
  final String? videoPath;
  final VideoPlayerController? controller;
  final Function(String)? onError;

  const EnhancedVideoPlayerWidget({
    super.key,
    required this.videoPath,
    this.onError,
  }) : controller = null;

  const EnhancedVideoPlayerWidget.withController({
    super.key,
    required this.controller,
    this.onError,
  }) : videoPath = null;

  @override
  State<EnhancedVideoPlayerWidget> createState() =>
      _EnhancedVideoPlayerWidgetState();
}

class _EnhancedVideoPlayerWidgetState extends State<EnhancedVideoPlayerWidget> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _initTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.controller != null) {
        _controller = widget.controller!;
      } else {
        // Check if format is potentially unsupported
        final uri = Uri.parse(widget.videoPath!);
        final formatHint = _getVideoFormatHint(widget.videoPath!);

        _controller = VideoPlayerController.networkUrl(
          uri,
          httpHeaders: {
            'Range': 'bytes=0-', // Add range header for better compatibility
          },
          formatHint: formatHint,
        );
      }

      // Set a timeout for initialization
      _initTimer = Timer(const Duration(seconds: 15), () {
        if (mounted && _chewieController == null) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Video loading timed out';
          });
          if (widget.onError != null) {
            widget.onError!(_errorMessage);
          }
        }
      });

      // Initialize the controller
      await _controller.initialize();

      if (mounted) {
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          autoPlay: false,
          looping: false,
          aspectRatio: _controller.value.aspectRatio,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 42, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'Error: $errorMessage',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(widget.videoPath!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open in browser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.dustyMauve,
                    ),
                  ),
                ],
              ),
            );
          },
          placeholder: const Center(child: CircularProgressIndicator()),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
        if (widget.onError != null) {
          widget.onError!(_errorMessage);
        }
        debugPrint('Video player error: $e');
      }
    }
  }

  // Try to provide format hint based on file extension
  VideoFormat? _getVideoFormatHint(String url) {
    final lowercaseUrl = url.toLowerCase();
    if (lowercaseUrl.endsWith('.mp4')) return VideoFormat.dash;
    if (lowercaseUrl.endsWith('.mov')) return VideoFormat.dash;
    if (lowercaseUrl.endsWith('.webm')) return VideoFormat.dash;
    return null;
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    _chewieController?.dispose();
    // Only dispose the controller if we created it
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: AppTheme.roseQuartz,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50.w, color: Colors.white),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'Unable to load video',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () async {
                  if (widget.videoPath != null) {
                    final uri = Uri.parse(widget.videoPath!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in browser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.dustyMauve,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Hero(
              tag: tag,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder:
                    (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                errorWidget:
                    (context, url, error) => const Center(
                      child: Icon(Icons.error, color: Colors.white, size: 50),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
