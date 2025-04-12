class FutureDream {
  final String id;
  final String title;
  final String description;
  final String imagePath;

  FutureDream({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  factory FutureDream.fromJson(Map<String, dynamic> json) {
    return FutureDream(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
    };
  }
}
