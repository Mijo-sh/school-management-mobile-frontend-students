import 'package:equatable/equatable.dart';

enum AiMessageRole { user, model }

class AiMessage extends Equatable {
  final AiMessageRole role;
  final String content;
  final DateTime timestamp;

  const AiMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AiMessage.fromJson(Map<String, dynamic> json) => AiMessage(
        role: json['role'] == 'user' ? AiMessageRole.user : AiMessageRole.model,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  @override
  List<Object?> get props => [role, content, timestamp];
}
