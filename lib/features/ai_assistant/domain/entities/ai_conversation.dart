import 'package:equatable/equatable.dart';

import 'ai_message.dart';

class AiConversation extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<AiMessage> messages;

  const AiConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  AiConversation copyWith({String? title, List<AiMessage>? messages}) {
    return AiConversation(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'created_at': createdAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory AiConversation.fromJson(Map<String, dynamic> json) => AiConversation(
        id: json['id'] as String,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        messages: (json['messages'] as List<dynamic>)
            .map((m) => AiMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [id, title, createdAt, messages];
}
