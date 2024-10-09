import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../custom_widgets/custom.dart';
import '../providers/providers.dart';
import '../utils/strings.dart';

class SideNavigationDrawer extends ConsumerWidget {
  const SideNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 50),
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : const AssetImage(Strings.avatar) as ImageProvider,
                  radius: 50,
                ),
                const SizedBox(height: 20),
                CustomText(
                  text: user?.displayName?.split(' ')[0] ?? 'User',
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  align: TextAlign.center,
                ),
                const SizedBox(height: 10),
                CustomText(
                  text: user?.email ?? 'user@email.com',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  align: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ListTile(
                  trailing: SvgPicture.asset(
                    Strings.settings,
                    colorFilter: const ColorFilter.mode(
                      Colors.blueGrey,
                      BlendMode.srcIn,
                    ),
                    width: 40,
                    height: 40,
                  ),
                  title: const CustomText(
                    text: 'Settings',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/settings');
                  },
                ),
                ListTile(
                  trailing: SvgPicture.asset(
                    Strings.feedback,
                    colorFilter: const ColorFilter.mode(
                      Colors.blueGrey,
                      BlendMode.srcIn,
                    ),
                    width: 40,
                    height: 40,
                  ),
                  title: const CustomText(
                    text: 'Feedback',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  trailing: SvgPicture.asset(
                    Strings.help,
                    colorFilter: const ColorFilter.mode(
                      Colors.blueGrey,
                      BlendMode.srcIn,
                    ),
                    width: 40,
                    height: 40,
                  ),
                  title: const CustomText(
                    text: 'Help Centre',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  trailing: SvgPicture.asset(
                    Strings.signout,
                    colorFilter: const ColorFilter.mode(
                      Colors.blueGrey,
                      BlendMode.srcIn,
                    ),
                    width: 40,
                    height: 40,
                  ),
                  title: const CustomText(
                    text: 'Exit',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    SystemNavigator.pop();
                  },
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: ThemeSwitch(),
          ),
        ],
      ),
    );
  }
}
