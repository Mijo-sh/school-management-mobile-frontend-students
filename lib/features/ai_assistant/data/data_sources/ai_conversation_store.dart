import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/ai_conversation.dart';
import '../../domain/entities/ai_message.dart';

/// مخزن محلي بس (بدون سيرفر إطلاقًا) لكل محادثات الذكاء الاصطناعي —
/// Singleton عبر الـ DI، نفس مبدأ HomeworkCompletionStore بالضبط.
class AiConversationStore extends ChangeNotifier {
  final SharedPreferences sharedPreferences;
  AiConversationStore({required this.sharedPreferences});

  static const _key = 'AI_CONVERSATIONS';

  List<AiConversation> _conversations = [];

  /// دايمًا مرتّبة حسب آخر نشاط (وقت آخر رسالة)، الأحدث أول.
  List<AiConversation> get conversations {
    final sorted = [..._conversations];
    sorted.sort((a, b) {
      final aTime = a.messages.isEmpty ? a.createdAt : a.messages.last.timestamp;
      final bTime = b.messages.isEmpty ? b.createdAt : b.messages.last.timestamp;
      return bTime.compareTo(aTime);
    });
    return List.unmodifiable(sorted);
  }

  /// محادثة "معلّقة" — انخلقت بالذاكرة بس، ولسا ما انبعتت فيها ولا
  /// رسالة. ما بتتخزن على القرص إطلاقًا لحد ما توصلها أول رسالة.
  AiConversation? _pendingConversation;

  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final jsonString = sharedPreferences.getString(_key);
    if (jsonString != null) {
      try {
        final list = jsonDecode(jsonString) as List<dynamic>;
        _conversations = list.map((e) => AiConversation.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _conversations = [];
      }
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    final jsonString = jsonEncode(_conversations.map((c) => c.toJson()).toList());
    await sharedPreferences.setString(_key, jsonString);
  }

  /// ينشئ محادثة جديدة **بالذاكرة بس** (مش مخزّنة على القرص لسا)،
  /// ويرجع الـ id تبعها. لو ما انبعتت فيها ولا رسالة وانفتحت محادثة
  /// جديدة تانية أو المستخدم طلع من التطبيق، بتضيع بصمت — وهيك بالظبط
  /// المطلوب (محادثة فاضية ما تتخزن).
  String createConversation() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _pendingConversation = AiConversation(
      id: id,
      title: 'محادثة جديدة',
      createdAt: DateTime.now(),
      messages: const [],
    );
    notifyListeners();
    return id;
  }

  AiConversation? getById(String id) {
    if (_pendingConversation?.id == id) return _pendingConversation;
    try {
      return _conversations.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// يضيف رسالة لمحادثة. لو كانت المحادثة لسا "معلّقة" (أول رسالة
  /// فيها)، بينقلها فعليًا للتخزين الدائم بهاللحظة بالذات — قبلها،
  /// كانت موجودة بالذاكرة بس.
  Future<void> addMessage(String conversationId, AiMessage message) async {
    // الحالة 1: أول رسالة بمحادثة معلّقة — ننقلها للتخزين الدائم الآن.
    if (_pendingConversation?.id == conversationId) {
      final pending = _pendingConversation!;
      final updatedMessages = [...pending.messages, message];

      String newTitle = pending.title;
      if (newTitle == 'محادثة جديدة' && message.role == AiMessageRole.user) {
        newTitle = message.content.length > 40 ? '${message.content.substring(0, 40)}...' : message.content;
      }

      final promoted = pending.copyWith(title: newTitle, messages: updatedMessages);
      _conversations.insert(0, promoted);
      _pendingConversation = null;
      await _persist();
      notifyListeners();
      return;
    }

    // الحالة 2: محادثة موجودة أصلًا بالتخزين — نضيف الرسالة عادي.
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;

    final current = _conversations[index];
    final updatedMessages = [...current.messages, message];

    String newTitle = current.title;
    if (newTitle == 'محادثة جديدة' && message.role == AiMessageRole.user) {
      newTitle = message.content.length > 40 ? '${message.content.substring(0, 40)}...' : message.content;
    }

    _conversations[index] = current.copyWith(title: newTitle, messages: updatedMessages);
    await _persist();
    notifyListeners();
  }

  /// إعادة تسمية يدوية — بتشتغل على المحادثات المخزّنة (يلي فيها
  /// رسالة عالأقل).
  Future<void> renameConversation(String id, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    final index = _conversations.indexWhere((c) => c.id == id);
    if (index == -1) return;

    _conversations[index] = _conversations[index].copyWith(title: newTitle.trim());
    await _persist();
    notifyListeners();
  }

  Future<void> deleteConversation(String id) async {
    _conversations.removeWhere((c) => c.id == id);
    if (_pendingConversation?.id == id) _pendingConversation = null;
    await _persist();
    notifyListeners();
  }
}