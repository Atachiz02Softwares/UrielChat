import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Strings {
  Strings._();

  final user = FirebaseAuth.instance.currentUser;

  static const String appName = 'Uriel Chat';

  static String apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
  static String instId = dotenv.env['SYSTEM_INSTRUCTION'] ?? '';

  static String systemInstructions = '';

  static const List<String> topics = [
        'AI',
        'Science & Technology',
        'Engineering',
        'Nature',
        'Mathematics',
        'Programming',
        'Current Affairs & Politics',
        'Philosophy',
        'Psychology',
        'History',
        'Literature',
        'Music',
        'Movies',
        'Sports',
        'Food',
        'Travel',
        userDefined
      ],
      tones = ['Formal', 'Friendly', 'Humorous', 'Professional', userDefined],
      modes = ['General', 'Casual', 'Technical', 'Spiritual', userDefined];

  static const String userDefined = 'User Defined', newChat = 'New Chat';

  static const String avatar = 'assets/images/avatar.png';
  static const String appIcon = 'assets/images/ic_launcher.png';
  static const String robot = 'assets/images/robot.png';

  static const String home = 'assets/icons/home.svg';
  static const String chat = 'assets/icons/chat.svg';
  static const String bookmark = 'assets/icons/bookmark.svg';
  static const String settings = 'assets/icons/settings.svg';
  static const String apple = 'assets/icons/apple.svg';
  static const String comments = 'assets/icons/comments.svg';
  static const String facebook = 'assets/icons/facebook.svg';
  static const String feedback = 'assets/icons/feedback.svg';
  static const String google = 'assets/icons/google.svg';
  static const String mail = 'assets/icons/mail.svg';
  static const String help = 'assets/icons/help.svg';
  static const String signout = 'assets/icons/signout.svg';
  static const String mic = 'assets/icons/mic.svg';
  static const String send = 'assets/icons/send.svg';
  static const String camera = 'assets/icons/camera.svg';
  static const String folder = 'assets/icons/folder.svg';
  static const String copy = 'assets/icons/copy.svg';
  static const String sweep = 'assets/icons/sweep.svg';
  static const String delete = 'assets/icons/delete.svg';
  static const String history = 'assets/icons/history.svg';
  static const String options = 'assets/icons/options.svg';
  static const String newChatIcon = 'assets/icons/new_chat.svg';

  static String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
