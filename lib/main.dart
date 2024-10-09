import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../utils/strings.dart';
import 'firebase/crud.dart';
import 'firebase_options.dart';
import 'screens/screens.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final systemInstructions = await CRUD().getSystemInstructions();
  if (systemInstructions != null) {
    Strings.systemInstructions = systemInstructions;
  }

  runApp(const ProviderScope(child: UrielChat()));
}

class UrielChat extends StatelessWidget {
  const UrielChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uriel Chat',
      theme: ThemeData.dark(),
      home: const AuthWrapper(),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/main': (context) => const MainScreen(),
        '/home': (context) => const HomeScreen(),
        '/chat': (context) => const ChatScreen(),
        '/bookmarks': (context) => const BookmarkScreen(),
        '/settings': (context) => const SettingScreen(),
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user != null) {
      return const MainScreen();
    } else {
      return const AuthScreen();
    }
  }
}
