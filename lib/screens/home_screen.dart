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
      if (_recentChats.isEmpty) {
        _loadChats();
      }
    });
  }

  Future<void> _loadChats() async {
    final chatService = ref.read(chatServiceProvider);
    final user = ref.read(userProvider);
    final textChats =
        await chatService.getRecentChats(user?.uid ?? '', Strings.userChats);
    final imageChats = await chatService.getRecentChats(
        user?.uid ?? '', Strings.userImageChats);

    final allChats = [...textChats, ...imageChats];
    _recentChats.addAll(allChats);

    if (allChats.isNotEmpty && mounted) {
      for (var i = 0; i < allChats.length; i++) {
        Future.delayed(Duration(milliseconds: 150 * i)).then((_) {
          if (mounted) {
            _listKey.currentState?.insertItem(
              _recentChats.length,
              duration: Duration(milliseconds: 150),
            );
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
        (ref.watch(userProvider)?.displayName?.split(' ')[0] ?? Strings.user)
            .capitalize();
    final currentPlan = ref.watch(planProvider);
    final recentChatsAsyncValue = ref.watch(recentChatsProvider);

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
                  recentChatsAsyncValue.when(
                    data: (recentChats) =>
                        _buildRecentChats(iconSize, recentChats),
                    loading: () => const Center(child: CustomProgressBar()),
                    error: (error, stack) =>
                        Center(child: _buildRecentChatState(iconSize, false)),
                  ),
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
                      arguments: <String, dynamic>{
                        'chatId': generateChatId(),
                        'searchQuery': searchQuery,
                        'fromRecent': true,
                      });
                  _searchController.clear();
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
              if (currentPlan == Strings.pl) {
                Navigator.pushNamed(context, '/image',
                    arguments: <String, dynamic>{'chatId': generateChatId()});
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

  Widget _buildRecentChats(
    double iconSize,
    List<Map<String, String>> recentChats,
  ) {
    if (recentChats.isEmpty) {
      return Center(child: _buildRecentChatState(iconSize, true));
    } else {
      return AnimatedList(
        key: _listKey,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        initialItemCount: recentChats.length,
        itemBuilder: (context, index, animation) {
          // Prevent index error
          if (index >= recentChats.length) return const SizedBox();
          final chat = recentChats[index];
          return _buildAnimatedChatItem(chat, animation);
        },
      );
    }
  }

  Widget _buildRecentChatState(double iconSize, bool isEmpty) {
    return Center(
      child: Column(
        children: [
          SvgPicture.asset(
            isEmpty ? Strings.empty : Strings.error,
            width: iconSize,
            height: iconSize,
          ),
          CustomText(
            text: isEmpty ? 'No recent chats yet...' : 'Error loading chats...',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedChatItem(
    Map<String, String> chat,
    Animation<double> animation,
  ) {
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
            isImageChat: chat['isImageChat'] == 'true',
          ),
        ),
      ),
    );
  }
}
