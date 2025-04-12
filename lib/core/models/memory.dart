class Memory {
  final String id;
  final String title;
  final String description;
  final List<MediaItem> mediaItems;
  final DateTime date;
  final String? url;

  Memory({
    required this.id,
    required this.title,
    required this.description,
    required this.mediaItems,
    required this.date,
    this.url,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      mediaItems:
          (json['mediaItems'] as List<dynamic>)
              .map((item) => MediaItem.fromJson(item as Map<String, dynamic>))
              .toList(),
      date: DateTime.parse(json['date'] as String),
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'mediaItems': mediaItems.map((item) => item.toJson()).toList(),
      'date': date.toIso8601String(),
      'url': url,
    };
  }
}

enum MediaType { image, video }

class MediaItem {
  final String path;
  final MediaType type;

  MediaItem({required this.path, required this.type});

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      path: json['path'] as String,
      type: MediaType.values.firstWhere(
        (e) => e.toString() == 'MediaType.${json['type']}',
        orElse: () => MediaType.image,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'path': path, 'type': type.toString().split('.').last};
  }
}
