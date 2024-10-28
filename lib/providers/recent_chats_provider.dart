import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uriel_chat/providers/providers.dart';

import '../utils/strings.dart';

final recentChatsProvider = StreamProvider<List<Map<String, String>>>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  final user = ref.watch(userProvider);
  if (user != null) {
    final userChatsStream =
        chatService.getRecentChatsStream(user.uid, Strings.userChats);
    final userImageChatsStream =
        chatService.getRecentChatsStream(user.uid, Strings.userImageChats);

    return Rx.combineLatest2<List<Map<String, String>>,
        List<Map<String, String>>, List<Map<String, String>>>(
      userChatsStream,
      userImageChatsStream,
      (userChats, userImageChats) => [...userChats, ...userImageChats],
    );
  } else {
    return Stream.value([]);
  }
});
