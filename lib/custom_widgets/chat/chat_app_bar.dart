import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/strings.dart';
import '../ui/custom_text.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onNewChat;
  final VoidCallback onDeleteChat;
  final double iconSize;

  const ChatAppBar({
    super.key,
    required this.title,
    required this.onNewChat,
    required this.onDeleteChat,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: CustomText(
        text: title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
      ),
      actions: [
        IconButton(
          tooltip: Strings.newChat,
          icon: SvgPicture.asset(
            Strings.newChatIcon,
            colorFilter: const ColorFilter.mode(
              Colors.blueGrey,
              BlendMode.srcIn,
            ),
            width: iconSize,
          ),
          onPressed: onNewChat,
        ),
        IconButton(
          icon: SvgPicture.asset(
            Strings.sweep,
            colorFilter: const ColorFilter.mode(
              Colors.blueGrey,
              BlendMode.srcIn,
            ),
            width: iconSize,
          ),
          tooltip: 'Clear Chat',
          onPressed: onDeleteChat,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
