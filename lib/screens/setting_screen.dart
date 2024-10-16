import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                if (user != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ProfilePicture(),
                      const SizedBox(height: 20),
                      CustomText(
                        text: user.displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      CustomText(
                        text: '${user.email}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
                ListTile(
                  leading: const Icon(
                    Icons.settings_rounded,
                    color: Colors.blueGrey,
                    size: 30,
                  ),
                  title: const CustomText(
                    text: 'AI Settings',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/ai_settings');
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_rounded,
                    color: Colors.blueGrey,
                    size: 30,
                  ),
                  title: const CustomText(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Utilities.showInfo(
                      context,
                      '**Privacy Policy**',
                      Strings.privacyPolicy,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.info,
                    color: Colors.blueGrey,
                    size: 30,
                  ),
                  title: const CustomText(
                    text: 'App Information',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Utilities.showInfo(
                      context,
                      '**App Information**',
                      Strings.appInfo,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.feedback_rounded,
                    color: Colors.blueGrey,
                    size: 30,
                  ),
                  title: const CustomText(
                    text: 'Feedback',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Utilities.showFeedbackBottomSheet(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.exit_to_app_rounded,
                    color: Colors.blueGrey,
                    size: 30,
                  ),
                  title: const CustomText(
                    text: 'Exit',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    SystemNavigator.pop();
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  icon: Strings.signout,
                  label: 'Sign Out',
                  buttonColor: Colors.red.shade900,
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
