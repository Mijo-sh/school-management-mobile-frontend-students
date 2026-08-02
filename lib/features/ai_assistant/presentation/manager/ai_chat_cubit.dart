import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/data_sources/ai_conversation_store.dart';
import '../../data/data_sources/gemini_chat_service.dart';
import '../../domain/entities/ai_conversation.dart';
import '../../domain/entities/ai_message.dart';

abstract class AiChatState extends Equatable {
  const AiChatState();
  @override
  List<Object?> get props => [];
}

class AiChatInitial extends AiChatState {
  const AiChatInitial();
}

class AiChatLoaded extends AiChatState {
  final AiConversation conversation;
  final bool isWaitingForReply;

  const AiChatLoaded({required this.conversation, this.isWaitingForReply = false});

  AiChatLoaded copyWith({AiConversation? conversation, bool? isWaitingForReply}) {
    return AiChatLoaded(
      conversation: conversation ?? this.conversation,
      isWaitingForReply: isWaitingForReply ?? this.isWaitingForReply,
    );
  }

  @override
  List<Object?> get props => [conversation, isWaitingForReply];
}

class AiChatCubit extends Cubit<AiChatState> {
  final AiConversationStore store;
  final GeminiChatService geminiService;

  AiChatCubit({required this.store, required this.geminiService}) : super(const AiChatInitial());

  /// يبلش محادثة جديدة كليًا، أو يفتح وحدة موجودة لو مررت [conversationId].
  Future<void> openConversation({String? conversationId}) async {
    await store.ensureLoaded();

    final String id;
    if (conversationId != null && store.getById(conversationId) != null) {
      id = conversationId;
    } else {
      id = store.createConversation();
    }

    final conversation = store.getById(id)!;
    emit(AiChatLoaded(conversation: conversation));
  }

  Future<void> startNewConversation() => openConversation();

  Future<void> sendMessage(String text) async {
    final current = state;
    if (current is! AiChatLoaded || text.trim().isEmpty) return;

    final userMessage = AiMessage(role: AiMessageRole.user, content: text.trim(), timestamp: DateTime.now());

    // تحديث فوري بالرسالة المرسلة + مؤشر انتظار
    await store.addMessage(current.conversation.id, userMessage);
    emit(current.copyWith(
      conversation: store.getById(current.conversation.id)!,
      isWaitingForReply: true,
    ));

    try {
      final replyText = await geminiService.sendMessage(
        history: current.conversation.messages, // قبل إضافة رسالة المستخدم الحالية
        newMessage: userMessage.content,
      );

      final aiMessage = AiMessage(role: AiMessageRole.model, content: replyText, timestamp: DateTime.now());
      await store.addMessage(current.conversation.id, aiMessage);

      emit(AiChatLoaded(
        conversation: store.getById(current.conversation.id)!,
        isWaitingForReply: false,
      ));
    } catch (e, stackTrace) {
      // 🔍 تشخيص مؤقت — احذفه بعد الحل
      print('❌ خطأ Gemini الحقيقي: $e');
      print('❌ النوع: ${e.runtimeType}');

      final errorMessage = AiMessage(
        role: AiMessageRole.model,
        content: 'صار خطأ بالاتصال، حاول مجددًا.',
        timestamp: DateTime.now(),
      );
      await store.addMessage(current.conversation.id, errorMessage);
      emit(AiChatLoaded(
        conversation: store.getById(current.conversation.id)!,
        isWaitingForReply: false,
      ));
    }
  }
}