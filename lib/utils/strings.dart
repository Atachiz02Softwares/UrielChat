import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Strings {
  Strings._();

  final user = FirebaseAuth.instance.currentUser;

  static const String appName = 'Uriel Chat';

  static String apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';

  static const List<String> topics = [
        '🤖 AI',
        '🔬 Science & Technology',
        '🛠️ Engineering',
        '🌿 Nature',
        '🔢 Mathematics',
        '💻 Programming',
        '📰 Current Affairs & Politics',
        '💭 Philosophy',
        '🧠 Psychology',
        '📜 History',
        '📚 Literature',
        '🎵 Music',
        '🎬 Movies',
        '🏅 Sports',
        '🍔 Food',
        '✈️ Travel',
        general
      ],
      tones = [
        '📜 Formal',
        '😊 Friendly',
        '😂 Humorous',
        '👔 Professional',
        general
      ],
      modes = ['😎 Casual', '🔧 Technical', '🕊️ Spiritual', general];

  static const String general = '😐 General', newChat = 'New Chat';

  static const String avatar = 'assets/images/avatar.png';
  static const String appIcon = 'assets/images/ic_launcher.png';

  static const String home = 'assets/icons/home.svg';
  static const String chat = 'assets/icons/chat.svg';
  static const String settings = 'assets/icons/settings.svg';
  static const String comments = 'assets/icons/comments.svg';
  static const String google = 'assets/icons/google.svg';
  static const String mail = 'assets/icons/mail.svg';
  static const String help = 'assets/icons/help.svg';
  static const String signout = 'assets/icons/signout.svg';
  static const String mic = 'assets/icons/mic.svg';
  static const String send = 'assets/icons/send.svg';
  static const String camera = 'assets/icons/camera.svg';
  static const String copy = 'assets/icons/copy.svg';
  static const String sweep = 'assets/icons/sweep.svg';
  static const String search = 'assets/icons/search.svg';
  static const String delete = 'assets/icons/delete.svg';
  static const String history = 'assets/icons/history.svg';
  static const String filter = 'assets/icons/filter.svg';
  static const String newChatIcon = 'assets/icons/new_chat.svg';
  static const String error = 'assets/icons/error.svg';
  static const String uriel = 'assets/icons/uriel.svg';

  static const String one = 'assets/images/one.jpeg';
  static const String two = 'assets/images/two.jpeg';
  static const String three = 'assets/images/three.jpeg';

  static const String chill = 'Chill, this feature is on its way...';

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

  static String systemInstructions = """
  You are Uriel, an AI assistant inspired by the angel Uriel, known for wisdom, 
  enlightenment, and guiding individuals towards greater understanding, when the 
  user asks for your name, tell them your name is Uriel. Uriel is powered by 
  Google’s Gemini AI and is integrated into the app titled "Uriel Chat" 
  developed by Atachiz02 Softwares. For more information about Atachiz02 
  Softwares, visit the following links: 
  - GitHub: https://github.com/Atachiz02Softwares 
  - LinkedIn: https://www.linkedin.com/company/atachiz02softwares 
  - Website: https://atachiz02-softwares.b12sites.com/ 
  Atachiz02 Softwares is a tech startup committed to creating innovative, 
  high-quality software solutions that enhance user experiences and drive 
  technology forward. Uriel Chat is a part of this commitment, blending advanced 
  AI capabilities with thoughtful interaction design.  Provide clear, 
  well-organized answers, and adapt your language and style best to suit the 
  context and complexity of the questions. BE STRAIGHTFORWARD! AVOID ASKING 
  UNNECESSARY QUESTIONS! ANSWER THE USER UPON REQUEST!
  """;
}
