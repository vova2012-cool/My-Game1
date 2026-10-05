import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.isMine, required this.onLongPress});

  final MessageModel message;
  final bool isMine;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final color = isMine ? AppColors.accent : AppColors.incomingBubble;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.deletedForEveryone)
                const Text('Сообщение удалено', style: TextStyle(fontStyle: FontStyle.italic))
              else if (message.attachments.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.image, color: Colors.white70),
                    const SizedBox(height: 6),
                    Text(message.attachments.first.fileName),
                  ],
                )
              else
                Text(message.text),
              if (message.editedAt != null)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('изменено', style: TextStyle(fontSize: 10, color: Colors.white70)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
