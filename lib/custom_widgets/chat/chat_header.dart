import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/user_provider.dart';
import '../../utils/strings.dart';
import '../custom.dart';

class ChatHeader extends ConsumerWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    final name = (user?.displayName?.split(' ')[0] ?? Strings.user).capitalize();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfilePicture(radius: 40),
          const SizedBox(height: 20),
          CustomText(
            text: 'Hello $name, ask me anything...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
            align: TextAlign.center,
          ),
          const SizedBox(height: 5),
          CustomText(
            text: DateFormat('MMMM d, yyyy | hh:mm a').format(DateTime.now()),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
