import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import 'firebase_options.dart';
import 'screens/screens.dart';
import 'utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final isRooted = await isDeviceRooted();
  if (isRooted) {
    runApp(const RootedDeviceScreen());
  } else {
    runApp(const ProviderScope(child: UrielChat()));
  }
}

class UrielChat extends StatelessWidget {
  const UrielChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      theme: ThemeData.dark(),
      home: const AuthWrapper(),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/main': (context) => const MainScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingScreen(),
        '/ai_settings': (context) => const AISettingScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, String>;
          final chatId = args['chatId']!;
          final searchQuery = args['searchQuery']!;
          return MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              searchQuery: searchQuery,
            ),
          );
        }
        return null;
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
      return const OnboardingScreen();
    }
  }
}