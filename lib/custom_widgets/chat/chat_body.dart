import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../utils/utils.dart';
import '../custom.dart';

class ChatBody extends ConsumerWidget {
  final List<Map<String, String>> messages;

  const ChatBody({
    super.key,
    required this.messages,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message['sender'] == 'user';
        final text = message['content'] ?? 'Unknown';
        final time = message['timestamp'] ?? '';

        return _buildChatBubble(
          context,
          text,
          time,
          isUser: isUser,
        );
      },
    );
  }

  String formatDateTime(String time) {
    final dateTime = DateTime.parse(time);
    return DateFormat('hh:mm a').format(dateTime);
  }

  Widget _buildChatBubble(
    BuildContext context,
    String text,
    String time, {
    bool isUser = false,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GlassContainer(
        borderRadius: 30,
        borderType: isUser ? BorderType.user : BorderType.ai,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              isUser
                  ? CustomText(
                      text: text,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      align: TextAlign.right,
                    )
                  : TypingText(
                      key: GlobalKey<TypingTextState>(),
                      text: text,
                    ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: formatDateTime(time),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  IconButton(
                    tooltip: 'Copy Text',
                    icon: SvgPicture.asset(
                      Strings.copy,
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                      width: 16,
                      height: 16,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      CustomSnackBar.showSnackBar(context, 'Copied to clipboard');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
