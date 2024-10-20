import 'package:flutter/material.dart';

import '../custom.dart';

class RecentChat extends StatelessWidget {
  final String chatId, firstMessage;

  const RecentChat(
      {super.key, required this.chatId, required this.firstMessage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/chat', arguments: <String, String>{
            'chatId': chatId,
            'searchQuery': '',
          });
        },
        child: GlassContainer(
          width: double.infinity,
          borderRadius: 20,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: CustomText(
              text: firstMessage,
              style: const TextStyle(fontSize: 18, color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
