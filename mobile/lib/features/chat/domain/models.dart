class UserModel {
  final String id;
  final String displayName;
  final String avatarUrl;
  final String status;
  final String bio;

  UserModel({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.status,
    required this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      displayName: (json['displayName'] ?? '').toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString(),
      status: (json['status'] ?? 'offline').toString(),
      bio: (json['bio'] ?? 'Available').toString(),
    );
  }
}

class ChatModel {
  final String id;
  final String type;
  final String title;
  final String avatarUrl;
  final bool pinned;
  final DateTime updatedAt;
  final List<UserModel> members;
  final MessageModel? lastMessage;

  ChatModel({
    required this.id,
    required this.type,
    required this.title,
    required this.avatarUrl,
    required this.pinned,
    required this.updatedAt,
    required this.members,
    required this.lastMessage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final membersJson = (json['members'] as List<dynamic>? ?? []);
    return ChatModel(
      id: (json['id'] ?? json['_id']).toString(),
      type: (json['type'] ?? 'direct').toString(),
      title: (json['title'] ?? '').toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString(),
      pinned: json['pinned'] == true,
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      members: membersJson.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList(),
      lastMessage: json['lastMessage'] == null
          ? (json['lastMessageId'] == null ? null : MessageModel.fromJson(json['lastMessageId']))
          : MessageModel.fromJson(json['lastMessage']),
    );
  }

  String resolveTitle(String myUserId) {
    if (type == 'group' && title.isNotEmpty) return title;
    final peer = members.firstWhere(
      (m) => m.id != myUserId,
      orElse: () => members.isNotEmpty ? members.first : UserModel(id: '', displayName: 'Unknown', avatarUrl: '', status: 'offline', bio: ''),
    );
    return peer.displayName;
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final bool deletedForEveryone;
  final DateTime createdAt;
  final DateTime? editedAt;
  final List<AttachmentModel> attachments;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.deletedForEveryone,
    required this.createdAt,
    required this.editedAt,
    required this.attachments,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final list = (json['attachments'] as List<dynamic>? ?? []);
    return MessageModel(
      id: (json['id'] ?? json['_id']).toString(),
      chatId: (json['chatId'] ?? '').toString(),
      senderId: (json['senderId'] is Map ? json['senderId']['_id'] : json['senderId']).toString(),
      text: (json['text'] ?? '').toString(),
      deletedForEveryone: json['deletedForEveryone'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      editedAt: DateTime.tryParse((json['editedAt'] ?? '').toString()),
      attachments: list.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class AttachmentModel {
  final String fileName;
  final String url;
  final String mimeType;

  AttachmentModel({required this.fileName, required this.url, required this.mimeType});

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      fileName: (json['fileName'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      mimeType: (json['mimeType'] ?? '').toString(),
    );
  }
}
