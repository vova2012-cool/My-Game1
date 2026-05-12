import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/cyber_avatar.dart';
import '../../domain/models.dart';
import '../widgets/message_bubble.dart';

class DialogScreen extends StatefulWidget {
  const DialogScreen({super.key, required this.chat});
  final ChatModel chat;

  @override
  State<DialogScreen> createState() => _DialogScreenState();
}

class _DialogScreenState extends State<DialogScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AppState>().loadMessages(widget.chat.id));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final title = widget.chat.resolveTitle(state.me?.id ?? '');
    final messages = state.messagesByChat[widget.chat.id] ?? [];
    final typing = state.typingMap[widget.chat.id] == true;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CyberAvatar(name: title, url: widget.chat.avatarUrl, radius: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    typing ? 'печатает...' : 'online',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messagesLoading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: false,
                    padding: const EdgeInsets.all(14),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMine = message.senderId == state.me?.id;

                      return MessageBubble(
                        message: message,
                        isMine: isMine,
                        onLongPress: () => _showActions(context, state, message),
                      );
                    },
                  ),
          ),
          _Composer(
            controller: _controller,
            onTyping: () => state.startTyping(widget.chat.id),
            onSend: () async {
              final text = _controller.text.trim();
              if (text.isEmpty) return;
              _controller.clear();
              await state.sendMessage(widget.chat.id, text);
              state.stopTyping(widget.chat.id);
            },
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context, AppState state, MessageModel message) {
    final mine = message.senderId == state.me?.id;
    if (!mine) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Редактировать'),
                onTap: () async {
                  Navigator.pop(context);
                  final edited = await _showEditDialog(context, message.text);
                  if (edited != null && edited.isNotEmpty) {
                    await state.editMessage(widget.chat.id, message.id, edited);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Удалить'),
                onTap: () async {
                  Navigator.pop(context);
                  await state.deleteMessage(widget.chat.id, message.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _showEditDialog(BuildContext context, String originalText) {
    final editController = TextEditingController(text: originalText);
    return showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Изменить сообщение'),
          content: TextField(controller: editController, maxLines: 3),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(onPressed: () => Navigator.pop(context, editController.text.trim()), child: const Text('Сохранить')),
          ],
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onTyping, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onTyping;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.emoji_emotions_outlined),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (_) => onTyping(),
                decoration: const InputDecoration(hintText: 'Сообщение...'),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: onSend,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
