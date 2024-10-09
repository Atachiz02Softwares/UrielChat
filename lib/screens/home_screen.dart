import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uriel_chat/utils/utils.dart';

import '../custom_widgets/custom.dart';
import '../providers/providers.dart';
import 'screens.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconSize = MediaQuery.of(context).size.width * 0.2;
    final user = ref.read(userProvider);
    final chatService = ref.read(chatServiceProvider);

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
                  FutureBuilder<List<String>>(
                    future: chatService.getRecentChats(user?.uid ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: const CustomProgressBar());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                Strings.history,
                                colorFilter: const ColorFilter.mode(
                                  Colors.blueGrey,
                                  BlendMode.srcIn,
                                ),
                                width: iconSize,
                                height: iconSize,
                              ),
                              const CustomText(
                                text: 'Error loading chats...',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                Strings.history,
                                colorFilter: const ColorFilter.mode(
                                  Colors.blueGrey,
                                  BlendMode.srcIn,
                                ),
                                width: iconSize,
                                height: iconSize,
                              ),
                              const CustomText(
                                text: 'No recent chats yet...',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final chatId = snapshot.data![index];
                            return buildChatCard(context, chatId);
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChatCard(BuildContext context, String chatId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/chat', arguments: chatId);
        },
        child: GlassContainer(
          width: double.infinity,
          borderRadius: 20,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomText(
              text: 'Chat ID: $chatId',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
