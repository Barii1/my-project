class ChatThread {
  final String id;
  final String title;
  final String subject; // e.g., CS, Math
  final DateTime time;
  final String preview;

  ChatThread({required this.id, required this.title, required this.subject, required this.time, required this.preview});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'time': time.toIso8601String(),
        'preview': preview,
      };

  static ChatThread fromJson(Map<String, dynamic> json) => ChatThread(
        id: json['id'] as String,
        title: json['title'] as String,
        subject: json['subject'] as String,
        time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
        preview: json['preview'] as String? ?? '',
      );
}
