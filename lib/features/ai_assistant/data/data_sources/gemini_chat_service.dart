import 'package:firebase_ai/firebase_ai.dart';

import '../../domain/entities/ai_message.dart';

/// ✅ ما عاد محتاجين أي مفتاح API بالكود إطلاقًا — firebase_ai بتاخد
/// الصلاحية مباشرة من مشروع Firebase (نفسو المستخدم للإشعارات)،
/// طالما فعّلت "AI Logic" من كونسول Firebase.
class GeminiChatService {
  final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3.5-flash',
  );

  /// يبعت رسالة جديدة، مع تمرير كامل تاريخ المحادثة السابق (history)
  /// حتى النموذج يفهم السياق الكامل، مش بس آخر رسالة لحالها.
  Future<String> sendMessage({
    required List<AiMessage> history,
    required String newMessage,
  }) async {
    final chat = _model.startChat(
      history: history
          .map((m) => Content(
        m.role == AiMessageRole.user ? 'user' : 'model',
        [TextPart(m.content)],
      ))
          .toList(),
    );

    final response = await chat.sendMessage(Content.text(newMessage));
    return response.text ?? 'ما قدرت أجاوب، حاول مجددًا.';
  }
}