import 'package:flutter/material.dart';
import 'package:uriel_chat/utils/strings.dart';

import '../../custom_widgets/ui/custom_text.dart';

class OnboardingPage extends StatelessWidget {
  final String imageUrl, title, subtitle;

  const OnboardingPage({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.3,
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  align: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CustomText(
                  text: subtitle,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                  ),
                  align: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      imageUrl: Strings.one,
      title: 'Discover AI-Powered Conversations',
      subtitle: 'Engage in intelligent and dynamic chats with Uriel',
    );
  }
}

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      imageUrl: Strings.two,
      title: 'Personalized Experience',
      subtitle: 'Get tailored responses and support from Uriel',
    );
  }
}

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      imageUrl: Strings.three,
      title: 'Join the AI Community',
      subtitle: 'Connect with others and share your AI experiences',
    );
  }
}
