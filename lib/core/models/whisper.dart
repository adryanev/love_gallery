class Whisper {
  final String id;
  final String title;
  final String audioPath;
  final String? transcript;

  Whisper({
    required this.id,
    required this.title,
    required this.audioPath,
    this.transcript,
  });

  factory Whisper.fromJson(Map<String, dynamic> json) {
    return Whisper(
      id: json['id'] as String,
      title: json['title'] as String,
      audioPath: json['audioPath'] as String,
      transcript: json['transcript'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'audioPath': audioPath,
      'transcript': transcript,
    };
  }
}
