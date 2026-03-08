import '../../../core/network/api_client.dart';
import '../domain/models.dart';

class ChatRepository {
  final ApiClient api;

  ChatRepository(this.api);

  Future<List<ChatModel>> listChats({String search = ''}) async {
    final response = await api.get('/api/chats', query: {'search': search});
    final chats = response.data['chats'] as List<dynamic>;
    return chats.map((e) => ChatModel.fromJson(e)).toList();
  }

  Future<List<MessageModel>> loadMessages(String chatId) async {
    final response = await api.get('/api/chats/$chatId/messages');
    final messages = response.data['messages'] as List<dynamic>;
    return messages.map((e) => MessageModel.fromJson(e)).toList();
  }

  Future<MessageModel> sendMessage(String chatId, String text) async {
    final response = await api.post('/api/messages', body: {'chatId': chatId, 'text': text});
    return MessageModel.fromJson(response.data['message']);
  }

  Future<void> editMessage(String messageId, String text) async {
    await api.patch('/api/messages/$messageId', body: {'text': text});
  }

  Future<void> deleteMessage(String messageId) async {
    await api.delete('/api/messages/$messageId');
  }

  Future<void> pinChat(String chatId) async {
    await api.post('/api/chats/$chatId/pin');
  }

  Future<void> unpinChat(String chatId) async {
    await api.delete('/api/chats/$chatId/pin');
  }
}
