import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../custom_widgets/custom.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Map<String, String>> _recentChats = [];

  @override
  void initState() {
    super.initState();
    ref.read(planProvider.notifier).fetchCurrentPlan(ref);

    // Fetch the chats and insert into the AnimatedList
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChats();
    });
  }

  Future<void> _loadChats() async {
    final chatService = ref.read(chatServiceProvider);
    final user = ref.read(userProvider);
    final chats = await chatService.getRecentChats(user?.uid ?? '');

    if (chats.isNotEmpty && mounted) {
      for (var i = 0; i < chats.length; i++) {
        Future.delayed(Duration(milliseconds: 150 * i), () {
          if (mounted) {
            _listKey.currentState?.insertItem(_recentChats.length,
                duration: Duration(milliseconds: 150 * i));
            _recentChats.add(chats[i]);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.of(context).size.width * 0.2;
    final userName =
        ref.watch(userProvider)?.displayName?.split(' ')[0] ?? 'User';
    final currentPlan = ref.watch(planProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [CurrentPlan()],
      ),
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
                  _buildWelcomeSection(userName),
                  const SizedBox(height: 30),
                  _buildSearchBar(currentPlan),
                  const SizedBox(height: 20),
                  _buildFeatureButtons(currentPlan),
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
                  _buildRecentChats(iconSize),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(String userName) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const ProfilePicture(),
          const SizedBox(width: 20),
          CustomText(
            text: 'Welcome to Uriel Chat, $userName',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(String currentPlan) {
    return GlassContainer(
      width: double.infinity,
      borderRadius: 50,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton(
              icon: SvgPicture.asset(
                Strings.search,
                colorFilter: const ColorFilter.mode(
                  Colors.blueGrey,
                  BlendMode.srcIn,
                ),
                width: 30,
                height: 30,
              ),
              onPressed: () {
                final searchQuery = _searchController.text;
                if (searchQuery.isNotEmpty) {
                  Navigator.pushNamed(context, '/chat',
                      arguments: <String, String>{
                        'chatId': generateChatId(),
                        'searchQuery': searchQuery,
                      });
                }
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
              ),
            ),
            MicButton(_searchController),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButtons(String currentPlan) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GlassButton(
            icon: Strings.image,
            label: 'Image Generation',
            color: Colors.green,
            onPressed: () {
              if (currentPlan == 'platinum') {
                Navigator.pushNamed(context, '/image',
                    arguments: <String, String>{'chatId': generateChatId()});
              } else {
                Utilities.promptUpgrade(context);
              }
            },
          ),
          const SizedBox(width: 20),
          GlassButton(
            icon: Strings.speak,
            label: 'Audio Chat',
            color: Colors.purple,
            onPressed: () {
              CustomSnackBar.showSnackBar(context, Strings.chill);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChats(double iconSize) {
    return FutureBuilder<List<Map<String, String>>>(
      future: ref
          .read(chatServiceProvider)
          .getRecentChats(ref.watch(userProvider)?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CustomProgressBar());
        } else if (snapshot.hasError) {
          return _buildErrorState(iconSize);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(iconSize);
        } else {
          return AnimatedList(
            key: _listKey,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            initialItemCount: _recentChats.length,
            itemBuilder: (context, index, animation) {
              // Prevent index error
              if (index >= _recentChats.length) return const SizedBox();
              final chat = _recentChats[index];
              return _buildAnimatedChatItem(chat, animation);
            },
          );
        }
      },
    );
  }

  Widget _buildErrorState(double iconSize) {
    return Center(
      child: Column(
        children: [
          SvgPicture.asset(
            Strings.error,
            colorFilter: const ColorFilter.mode(
              Colors.blueGrey,
              BlendMode.srcIn,
            ),
            width: iconSize,
            height: iconSize,
          ),
          const CustomText(
            text: 'Error loading chats...',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double iconSize) {
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
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedChatItem(
      Map<String, String> chat, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: FadeTransition(
          opacity: animation,
          child: RecentChat(
            chatId: chat['chatId']!,
            firstMessage: chat['firstMessage']!,
          ),
        ),
      ),
    );
  }
}
