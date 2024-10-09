class ChatMessage {
  final String sender;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      sender: map['sender'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  bool containsKey(String key) {
    return toMap().containsKey(key);
  }

  String operator [](String key) {
    return toMap()[key];
  }
}
