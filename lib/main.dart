import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'screens/screens.dart';
import 'utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activate Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // TODO: DELETE THIS LINE LATER
  );

  final isRooted = await isDeviceRooted();
  if (isRooted) {
    runApp(const RootedDeviceScreen());
  } else {
    runApp(const ProviderScope(child: UrielChat()));
  }
}

class UrielChat extends ConsumerWidget {
  const UrielChat({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Utilities.initializeRemoteConfig(ref); // Initialize Remote Configs

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
