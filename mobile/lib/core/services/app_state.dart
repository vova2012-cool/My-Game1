import 'dart:async';

import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../storage/token_storage.dart';
import 'socket_service.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/chat/data/chat_repository.dart';
import '../../features/chat/domain/models.dart';

class AppState extends ChangeNotifier {
  AppState({required String apiBase, required String socketBase})
      : _apiBase = apiBase,
        _socketBase = socketBase,
        apiClient = ApiClient(apiBase),
        tokenStorage = TokenStorage(),
        socketService = SocketService() {
    authRepository = AuthRepository(apiClient);
    chatRepository = ChatRepository(apiClient);
  }

  final String _apiBase;
  final String _socketBase;
  final ApiClient apiClient;
  final TokenStorage tokenStorage;
  final SocketService socketService;

  late final AuthRepository authRepository;
  late final ChatRepository chatRepository;

  String? token;
  UserModel? me;
  bool booting = true;
  bool authLoading = false;
  bool chatsLoading = false;
  bool messagesLoading = false;

  List<ChatModel> chats = [];
  Map<String, List<MessageModel>> messagesByChat = {};
  Map<String, bool> typingMap = {};

  Future<void> bootstrap() async {
    token = await tokenStorage.loadToken();
    if (token != null) {
      apiClient.setToken(token);
      await _loadMe();
      await loadChats();
      _connectSocket();
    }
    booting = false;
    notifyListeners();
  }

  bool get isAuthorized => token != null && me != null;

  Future<void> loginOrRegister({required String identifier, required String password, String? displayName}) async {
    authLoading = true;
    notifyListeners();

    try {
      AuthResult result;
      if (displayName == null || displayName.isEmpty) {
        result = await authRepository.login(identifier: identifier, password: password);
      } else {
        result = await authRepository.register(identifier: identifier, password: password, displayName: displayName);
      }

      token = result.token;
      me = result.user;
      apiClient.setToken(token);
      await tokenStorage.saveToken(token!);
      _connectSocket();
      await loadChats();
    } finally {
      authLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    token = null;
    me = null;
    chats = [];
    messagesByChat = {};
    typingMap = {};
    apiClient.setToken(null);
    await tokenStorage.clear();
    socketService.disconnect();
    notifyListeners();
  }

  Future<void> _loadMe() async {
    final response = await apiClient.get('/api/auth/me');
    me = UserModel.fromJson(response.data['user']);
  }

  Future<void> updateProfile({required String displayName, required String bio}) async {
    final response = await apiClient.patch('/api/profile', body: {
      'displayName': displayName,
      'bio': bio,
    });
    me = UserModel.fromJson(response.data['user']);
    notifyListeners();
  }

  Future<void> loadChats({String search = ''}) async {
    chatsLoading = true;
    notifyListeners();
    try {
      chats = await chatRepository.listChats(search: search);
      chats.sort((a, b) {
        if (a.pinned == b.pinned) {
          return b.updatedAt.compareTo(a.updatedAt);
        }
        return a.pinned ? -1 : 1;
      });
    } finally {
      chatsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String chatId) async {
    messagesLoading = true;
    notifyListeners();
    try {
      final messages = await chatRepository.loadMessages(chatId);
      messagesByChat[chatId] = messages;
      socketService.emit('chat:join', {'chatId': chatId});
    } finally {
      messagesLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String chatId, String text) async {
    final sent = await chatRepository.sendMessage(chatId, text);
    final list = messagesByChat.putIfAbsent(chatId, () => []);
    list.add(sent);
    notifyListeners();
  }

  Future<void> editMessage(String chatId, String messageId, String text) async {
    await chatRepository.editMessage(messageId, text);
    final list = messagesByChat[chatId];
    if (list == null) return;
    final idx = list.indexWhere((m) => m.id == messageId);
    if (idx >= 0) {
      final old = list[idx];
      list[idx] = MessageModel(
        id: old.id,
        chatId: old.chatId,
        senderId: old.senderId,
        text: text,
        deletedForEveryone: false,
        createdAt: old.createdAt,
        editedAt: DateTime.now(),
        attachments: old.attachments,
      );
      notifyListeners();
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await chatRepository.deleteMessage(messageId);
    final list = messagesByChat[chatId];
    if (list == null) return;
    list.removeWhere((m) => m.id == messageId);
    notifyListeners();
  }

  Future<void> togglePin(ChatModel chat) async {
    if (chat.pinned) {
      await chatRepository.unpinChat(chat.id);
    } else {
      await chatRepository.pinChat(chat.id);
    }
    await loadChats();
  }

  void startTyping(String chatId) {
    socketService.emit('typing:start', {'chatId': chatId});
  }

  void stopTyping(String chatId) {
    socketService.emit('typing:stop', {'chatId': chatId});
  }

  void _connectSocket() {
    if (token == null) return;
    socketService.connect(url: _socketBase, token: token!);

    socketService.on('message:new', (payload) {
      final message = MessageModel.fromJson(payload['message']);
      final list = messagesByChat.putIfAbsent(message.chatId, () => []);
      if (!list.any((e) => e.id == message.id)) {
        list.add(message);
      }
      loadChats();
      notifyListeners();
    });

    socketService.on('message:updated', (payload) {
      final message = MessageModel.fromJson(payload['message']);
      final list = messagesByChat[message.chatId];
      if (list == null) return;
      final idx = list.indexWhere((e) => e.id == message.id);
      if (idx != -1) {
        list[idx] = message;
        notifyListeners();
      }
    });

    socketService.on('message:deleted', (payload) {
      final messageId = payload['messageId'].toString();
      for (final entry in messagesByChat.entries) {
        entry.value.removeWhere((m) => m.id == messageId);
      }
      notifyListeners();
    });

    socketService.on('typing:start', (payload) {
      typingMap[payload['chatId'].toString()] = true;
      notifyListeners();
    });

    socketService.on('typing:stop', (payload) {
      typingMap[payload['chatId'].toString()] = false;
      notifyListeners();
    });
  }
}
