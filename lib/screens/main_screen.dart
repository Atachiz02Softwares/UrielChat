import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers/chat_provider.dart';
import '../utils/utils.dart';
import 'screens.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    ChatScreen(chatId: generateChatId()), // Use generateChatId method
    const SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final iconSize = width * 0.08;

    return Scaffold(
      body: SafeArea(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              Strings.home,
              colorFilter: const ColorFilter.mode(
                Colors.blueGrey,
                BlendMode.srcIn,
              ),
              width: iconSize,
              height: iconSize,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              Strings.chat,
              colorFilter: const ColorFilter.mode(
                Colors.blueGrey,
                BlendMode.srcIn,
              ),
              width: iconSize,
              height: iconSize,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              Strings.settings,
              colorFilter: const ColorFilter.mode(
                Colors.blueGrey,
                BlendMode.srcIn,
              ),
              width: iconSize,
              height: iconSize,
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
