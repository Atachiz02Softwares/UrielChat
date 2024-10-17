import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../providers/plan_provider.dart';
import '../../utils/strings.dart';
import '../ui/custom_text.dart';

class ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlan = ref.watch(planProvider);

    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white, size: 30),
      backgroundColor: Colors.black,
      title: CustomText(
        text: title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
      ),
      actions: [
        CustomText(
          text: '${currentPlan.toUpperCase()} PLAN',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 10),
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
