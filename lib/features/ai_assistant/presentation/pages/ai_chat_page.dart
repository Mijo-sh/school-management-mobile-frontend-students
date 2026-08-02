import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localization.dart';

import '../../../../core/injector/injector_container.dart';
import '../../../profile/presentation/pages/authenticated_avatar.dart';
import '../../../shared/presentation/widgets/DecorativeHeaderBackground.dart';
import '../../data/data_sources/ai_conversation_store.dart';
import '../../domain/entities/ai_conversation.dart';
import '../../domain/entities/ai_message.dart';
import '../manager/ai_chat_cubit.dart';

class AiChatPage extends StatelessWidget {
  const AiChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<AiChatCubit>()..openConversation(),
      child: const _AiChatView(),
    );
  }
}

class _AiChatView extends StatefulWidget {
  const _AiChatView();

  @override
  State<_AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<_AiChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<AiChatCubit>().sendMessage(text);
    _controller.clear();
  }

  /// اللوحة الموحّدة — "محادثة جديدة" فوق، وتحتها قائمة المحادثات
  /// السابقة، الاثنين بمكان واحد بس.
  void _openMenu(BuildContext context) {
    final chatCubit = context.read<AiChatCubit>();
    final store = di<AiConversationStore>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final cs = Theme.of(context).colorScheme;
          return ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              final conversations = store.conversations;
              return Column(
                children: [
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
                  ),
                  // ── محادثة جديدة، فوق دايمًا ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ListTile(
                      leading: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                        child: Icon(Icons.add_rounded, color: cs.onPrimary),
                      ),
                      title: Text('ai_chat_new_conversation'.tr(context), style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary)),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        chatCubit.startNewConversation();
                      },
                    ),
                  ),
                  const Divider(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text('ai_chat_previous_conversations'.tr(context),
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: cs.onSurface.withOpacity(0.5))),
                    ),
                  ),
                  Expanded(
                    child: conversations.isEmpty
                        ? Center(
                      child: Text('ai_chat_no_previous_conversations'.tr(context), style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
                    )
                        : ListView.builder(
                      controller: scrollController,
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final c = conversations[index];
                        return ListTile(
                          leading: Icon(Icons.chat_bubble_outline_rounded, color: cs.onSurface.withOpacity(0.5)),
                          title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${c.messages.length} ${'ai_chat_message_count'.tr(context)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => _showRenameDialog(context, store, c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                onPressed: () => store.deleteConversation(c.id),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            chatCubit.openConversation(conversationId: c.id);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, AiConversationStore store, AiConversation conversation) async {
    final controller = TextEditingController(text: conversation.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('ai_chat_rename_title'.tr(context)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'ai_chat_rename_hint'.tr(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('button_cancel'.tr(context)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text('ai_chat_save'.tr(context)),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.trim().isNotEmpty) {
      await store.renameConversation(conversation.id, newTitle.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          // ── هيدر مخصص لهالصفحة بس ──
          _AiChatHeader(onMenuTap: () => _openMenu(context)),

          Expanded(
            child: BlocConsumer<AiChatCubit, AiChatState>(
              listener: (context, state) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });
              },
              builder: (context, state) {
                if (state is! AiChatLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = state.conversation.messages;

                return Column(
                  children: [
                    Expanded(
                      child: messages.isEmpty
                          ? Center(
                        child: Text(
                          'ai_chat_empty_state'.tr(context),
                          style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
                        ),
                      )
                          : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(14),
                        itemCount: messages.length,
                        itemBuilder: (context, index) => _MessageBubble(message: messages[index]),
                      ),
                    ),
                    if (state.isWaitingForReply)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    _InputBar(controller: _controller, onSend: _send),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// هيدر مخصص بس لصفحة الدردشة — عنوان بالنص، وزر وحيد على اليمين
/// بيفتح اللوحة الموحّدة (محادثة جديدة + المحادثات السابقة).
class _AiChatHeader extends StatelessWidget {
  final VoidCallback onMenuTap;
  const _AiChatHeader({required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Stack(
        children: [
          // 👇 نفس الخلفية الزخرفية المستخدمة بكل هيدرز التطبيق —
          // Positioned.fill حتى حجم الهيدر يتحدد من المحتوى (الصف
          // تحت)، مش من الخلفية نفسها.
          const Positioned.fill(child: DecorativeHeaderBackground()),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  // موازنة بصرية جهة اليسار حتى العنوان يضل بمنتصف الشاشة الحقيقي
                  const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      'ai_chat_title'.tr(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onPrimary, fontSize: 19, fontWeight: FontWeight.w700),
                    ),
                  ),
                  // ── الزر الموحّد، على اليمين ──
                  IconButton(
                    icon: Icon(Icons.forum_rounded, color: cs.onPrimary),
                    onPressed: onMenuTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AiMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUser = message.role == AiMessageRole.user;

    final avatar = ClipOval(
      child: Container(
        width: 32,
        height: 32,
        color: isUser ? cs.surfaceContainer : cs.primary.withOpacity(0.12),
        child: isUser
            ? AuthenticatedAvatar(
          size: 32,
          borderRadius: BorderRadius.circular(16),
          fallback: Icon(Icons.person_rounded, size: 18, color: cs.onSurface.withOpacity(0.5)),
        )
            : Padding(
          padding: const EdgeInsets.all(5),
          child: Image.asset(
            'assets/images/robot_purple.png',

            errorBuilder: (_, __, ___) => Icon(Icons.smart_toy_rounded, size: 18, color: cs.primary),
          ),
        ),
      ),
    );

    final bubble = Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isUser ? cs.surfaceContainer : cs.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.content,
          textAlign: TextAlign.end,
          style: TextStyle(fontSize: 14, color: cs.onSurface),
        ),
      ),
    );

    return Align(
      // 👇 AlignmentDirectional بدل Alignment.centerLeft/Right — بهيك
      // "المستخدم" دايمًا بالطرف النهائي (end) و"الذكاء الاصطناعي"
      // بالطرف الأولي (start)، بغض النظر عن اللغة الحالية (عربي RTL
      // أو إنكليزي LTR). ترتيب عناصر الـ Row نفسو أصلًا يتبع نفس
      // المنطق تلقائيًا (أول عنصر = start، آخر عنصر = end).
      alignment: isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isUser ? [bubble, const SizedBox(width: 6), avatar] : [avatar, const SizedBox(width: 6), bubble],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [

            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'ai_chat_input_hint'.tr(context),
                  filled: true,
                  fillColor: cs.surfaceContainer,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            // 👇 أيقونة الروبوت وقت الحقل فاضي، تتحول لزر الإرسال
            // فورًا بمجرد ما تبلش تكتب.
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final hasText = value.text.trim().isNotEmpty;
                return hasText
                    ? IconButton(
                  icon: Icon(Icons.send_rounded, color: cs.primary),
                  onPressed: onSend,
                )
                    : Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Image.asset(
                      'assets/images/robot_purple.png',
                      errorBuilder: (_, __, ___) => Icon(Icons.smart_toy_rounded, color: cs.primary),
                    ),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}