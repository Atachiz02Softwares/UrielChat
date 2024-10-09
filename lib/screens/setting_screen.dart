import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../custom_widgets/custom.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const CustomText(
          text: 'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: BackgroundContainer(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (user != null) ...[
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : const AssetImage(Strings.avatar) as ImageProvider,
                    radius: 80,
                  ),
                  const SizedBox(height: 20),
                  CustomText(text: 'Name: ${user.displayName}'),
                  CustomText(text: 'Email: ${user.email}'),
                ],
                const SizedBox(height: 20),
                CustomButton(
                  icon: Strings.signout,
                  label: 'Sign Out',
                  color: Colors.red.shade900,
                  onPressed: () async {
                    final authNotifier = ref.read(authProvider.notifier);
                    await authNotifier.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/auth', (route) => false);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
