class ChatMessage {
  final int? id;
  final int? userId;
  final String username;
  final String text;
  final DateTime? createdAt;

  const ChatMessage({
    this.id,
    this.userId,
    required this.username,
    required this.text,
    this.createdAt,
  });

  // ========================================
  // CREAR MENSAJE DESDE JSON
  // ========================================

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      username: json['username']?.toString() ?? 'Desconocido',
      text: json['text']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
