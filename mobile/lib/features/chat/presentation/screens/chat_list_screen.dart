import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/cyber_avatar.dart';
import '../../domain/models.dart';
import 'dialog_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              onChanged: (v) => state.loadChats(search: v),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Поиск чатов'),
            ),
          ),
          Expanded(
            child: state.chatsLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => state.loadChats(search: _search.text.trim()),
                    child: ListView.separated(
                      itemCount: state.chats.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final chat = state.chats[index];
                        final title = chat.resolveTitle(state.me?.id ?? '');
                        final subtitle = chat.lastMessage?.text.isNotEmpty == true
                            ? chat.lastMessage!.text
                            : chat.lastMessage?.attachments.isNotEmpty == true
                                ? '📷 Изображение'
                                : 'Начните диалог';
                        final unread = (index + 1) % 4 == 0 ? (index % 7) + 1 : 0;

                        return ListTile(
                          leading: CyberAvatar(name: title, url: chat.avatarUrl),
                          title: Row(
                            children: [
                              Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
                              if (chat.pinned)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(Icons.push_pin, size: 16, color: AppColors.accent),
                                ),
                            ],
                          ),
                          subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: unread > 0
                              ? CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppColors.accent,
                                  child: Text('$unread', style: const TextStyle(fontSize: 12)),
                                )
                              : null,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DialogScreen(chat: chat)),
                          ),
                          onLongPress: () => state.togglePin(chat),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
