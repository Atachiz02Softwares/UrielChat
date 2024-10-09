import 'package:flutter/material.dart';

import 'custom_text.dart';

class ThemeSwitch extends StatefulWidget {
  const ThemeSwitch({super.key});

  @override
  State<ThemeSwitch> createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isDarkMode = false;
                // TODO: Add logic for switching to light theme
              });
            },
            child: _buttonContainer(
              icon: Icons.wb_sunny_outlined,
              text: 'Light',
              isActive: !isDarkMode,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                isDarkMode = true;
                // TODO: Add logic for switching to dark theme
              });
            },
            child: _buttonContainer(
              icon: Icons.nights_stay_outlined,
              text: 'Dark',
              isActive: isDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonContainer({
    required IconData icon,
    required String text,
    required bool isActive,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey,
            size: 30,
          ),
          const SizedBox(width: 8),
          CustomText(
            text: text,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
