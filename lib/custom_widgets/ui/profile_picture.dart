import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/user_provider.dart';
import '../../utils/strings.dart';

class ProfilePicture extends ConsumerWidget {
  final double? radius;

  const ProfilePicture({super.key, this.radius = 80});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);

    return CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: user?.photoURL != null
          ? NetworkImage(user!.photoURL!)
          : const AssetImage(Strings.avatar) as ImageProvider,
      radius: radius,
    );
  }
}
