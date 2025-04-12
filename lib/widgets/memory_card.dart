import 'package:flutter/material.dart';
import 'package:love_gallery/core/models/memory.dart';
import 'package:love_gallery/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback onTap;

  const MemoryCard({super.key, required this.memory, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppTheme.petalPink,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppTheme.dustyMauve.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: _buildMediaPreview(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    memory.description.length > 100
                        ? '${memory.description.substring(0, 100)}...'
                        : memory.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (memory.mediaItems.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.collections,
                                size: 16,
                                color: AppTheme.dustyMauve,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${memory.mediaItems.length} items',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.dustyMauve,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (memory.url != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.link,
                                size: 16,
                                color: AppTheme.dustyMauve,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Link',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.dustyMauve,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (memory.mediaItems.isEmpty) {
      return Container(
        height: 180,
        color: AppTheme.roseQuartz,
        child: Center(
          child: Icon(Icons.image, size: 50, color: AppTheme.blushPink),
        ),
      );
    }

    final firstMedia = memory.mediaItems.first;

    if (firstMedia.type == MediaType.image) {
      return Hero(
        tag: 'memory-${memory.id}-0',
        child: CachedNetworkImage(
          imageUrl: firstMedia.path,
          height: 180,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildShimmerPlaceholder(),
          errorWidget: (context, url, error) {
            return Container(
              height: 180,
              color: AppTheme.roseQuartz,
              child: Center(
                child: Icon(Icons.image, size: 50, color: AppTheme.blushPink),
              ),
            );
          },
        ),
      );
    } else {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            color: AppTheme.roseQuartz,
          ),
          Icon(
            Icons.play_circle_outline,
            size: 50,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ],
      );
    }
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
              height: 180,
              color: Colors.white,
            ),
          ),
    );
  }
}
