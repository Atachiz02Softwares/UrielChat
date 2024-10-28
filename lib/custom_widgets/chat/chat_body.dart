import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';
import '../../utils/utils.dart';
import '../custom.dart';

class ChatBody extends ConsumerStatefulWidget {
  final List<Map<String, String>> messages;
  final String chatId;

  const ChatBody({
    super.key,
    required this.messages,
    required this.chatId,
  });

  @override
  ConsumerState<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends ConsumerState<ChatBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(ChatBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasShownTypingAnimation = ref
        .watch(typingAnimationProvider.notifier)
        .hasShownAnimation(widget.chatId);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final isUser = message['sender'] == Strings.user;
        final text = message['content'] ?? 'Unknown';
        final time = message['timestamp'] ?? '';

        return _buildChatBubble(
          context,
          text,
          time,
          isUser: isUser,
          isLastMessage: index == widget.messages.length - 1,
          hasShownTypingAnimation: hasShownTypingAnimation,
          ref: ref,
        );
      },
    );
  }

  Widget _buildChatBubble(
    BuildContext context,
    String text,
    String time, {
    bool isUser = false,
    bool isLastMessage = false,
    required bool hasShownTypingAnimation,
    required WidgetRef ref,
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
                      text: text.trim(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      align: TextAlign.right,
                    )
                  : (isLastMessage && !hasShownTypingAnimation
                      ? TypingText(
                          key: GlobalKey<TypingTextState>(),
                          text: text,
                          onComplete: () {
                            ref
                                .read(typingAnimationProvider.notifier)
                                .showAnimation(widget.chatId);
                            _scrollToBottom();
                          },
                        )
                      : MarkdownBody(
                          data: text,
                          styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 16),
                            textAlign: WrapAlignment.start,
                          ),
                        )),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: Strings.formatDateTime(time),
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
                      CustomSnackBar.showSnackBar(
                          context, 'Copied to clipboard');
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
