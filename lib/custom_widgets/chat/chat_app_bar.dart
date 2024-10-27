import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uriel_chat/custom_widgets/custom.dart';

import '../../utils/strings.dart';

class ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onNewChat;
  final VoidCallback onDeleteChat;
  final double iconSize;
  final Widget? leading;

  const ChatAppBar({
    super.key,
    required this.title,
    required this.onNewChat,
    required this.onDeleteChat,
    required this.iconSize,
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: leading,
      iconTheme: const IconThemeData(color: Colors.white, size: 30),
      backgroundColor: Colors.black,
      title: CustomText(
        text: title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
      ),
      actions: [
        CurrentPlan(),
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
