import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uriel_chat/utils/utils.dart';

import '../custom_widgets/custom.dart';
import '../providers/providers.dart';
import 'screens.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);

    return Scaffold(
      endDrawer: const SideNavigationDrawer(),
      body: Stack(
        children: [
          const BackgroundContainer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Builder(
                        builder: (context) {
                          return IconButton(
                            icon: const Icon(
                              Icons.menu_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : const AssetImage(Strings.avatar)
                                  as ImageProvider,
                          radius: 80,
                        ),
                        const SizedBox(width: 20),
                        CustomText(
                          text:
                              'Welcome to Uriel Chat, ${user?.displayName?.split(' ')[0] ?? 'User'}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          align: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  GlassContainer(
                    width: double.infinity,
                    borderRadius: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.search_rounded,
                              color: Colors.grey,
                              size: 30,
                            ),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Ask me anything...',
                                border: InputBorder.none,
                                hintStyle:
                                    GoogleFonts.poppins(color: Colors.grey),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.mic_rounded,
                              color: Colors.grey,
                              size: 30,
                            ),
                            onPressed: () {
                              CustomSnackBar.showSnackBar(
                                  context, Strings.chill);
                            },
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(
                              Icons.photo_camera_rounded,
                              color: Colors.grey,
                              size: 30,
                            ),
                            onPressed: () {
                              CustomSnackBar.showSnackBar(
                                  context, Strings.chill);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CustomText(
                    text: 'Recent Chats',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      buildChatCard('This is my favourite gaming device...'),
                      buildChatCard(
                          "Check out what Uber Air's Skyport looks like..."),
                      buildChatCard('UI Colour in hex format...'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChatCard(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: InkWell(
        onTap: () {},
        child: GlassContainer(
          width: double.infinity,
          borderRadius: 20,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomText(
              text: text,
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
