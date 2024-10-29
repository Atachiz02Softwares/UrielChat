import 'package:intl/intl.dart';

class Strings {
  Strings._();

  static const String appName = 'Uriel Chat';

  static final String users = 'users',
      ai = 'AI',
      user = 'user',
      chats = 'chats',
      userChats = 'userChats',
      userImageChats = 'userImageChats';

  static String payStackSecretKey = '', payStackPublicKey = '';

  static String freeAPIKey = '', paidAPIKey = '', stabilityAPIKey = '';

  static String freeModel = '', paidModel = '';

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
  static const String google = 'assets/icons/google.svg';
  static const String mail = 'assets/icons/mail.svg';
  static const String signout = 'assets/icons/signout.svg';
  static const String mic = 'assets/icons/mic.svg';
  static const String send = 'assets/icons/send.svg';
  static const String image = 'assets/icons/image.svg';
  static const String copy = 'assets/icons/copy.svg';
  static const String sweep = 'assets/icons/sweep.svg';
  static const String search = 'assets/icons/search.svg';
  static const String empty = 'assets/icons/empty.svg';
  static const String error = 'assets/icons/error.svg';
  static const String filter = 'assets/icons/filter.svg';
  static const String newChatIcon = 'assets/icons/new_chat.svg';
  static const String dollar = 'assets/icons/dollar.svg';
  static const String shield = 'assets/icons/shield.svg';
  static const String speak = 'assets/icons/speak.svg';
  static const String download = 'assets/icons/download.svg';

  static const String one = 'assets/images/one.jpeg';
  static const String two = 'assets/images/two.jpeg';
  static const String three = 'assets/images/three.jpeg';

  static const String email = 'morpheusoftwares@gmail.com';

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

  static String formatDateTime(String time) {
    final dateTime = DateTime.parse(time);
    return DateFormat('hh:mm a').format(dateTime);
  }

  static const String rootedDeviceMessage = """
**For security reasons, you cannot use $appName on a rooted or jailbroken device. Please use a non-rooted device or a device with an unmodified operating system to access the app.**
  
**If you believe this is an error, please contact support for assistance, but first, check if your device is not an emulator/simulator, not in developer mode, or has not been tampered with.**
  
**For support, contact us at [$email](mailto:$email).**
""";

  static const String systemInstructions = """
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

  static String privacyPolicy = """
# **Privacy Policy**

## 1. **Information We Collect**

We collect the following information for analytics purposes and to provide
better services to our users:
- **User Data:** We collect information you provide when you sign up for an
account, including your name, email address, and profile picture if any.
- **User Chats:** We collect information about your chats, including messages
you send and receive and the time and date these messages were sent/received.
These messages are securely stored to provide you with a seamless chatting
experience, and it is our intention to integrate end-to-end chat encryption soon.

## 2. **How We Use Information**

We use the information we collect to provide, maintain, and improve our app and
general services.

## 3. **Information Sharing**

We do not share personal information with companies, organizations, or individuals
outside of our company except in the following cases:

- **With Your Consent:** We may share your information with third parties if you
give us explicit consent.
- **For Legal Reasons:** We may share your information if required by law or to
protect the rights and safety of our users and others.

## 4. **Data Security**

We implement appropriate security measures to protect your information from
unauthorized access, alteration, disclosure, or destruction.

## 5. **Plan Upgrade**
- Upgrading to a higher tier will reset your daily message count immediately.
- We will not refund any payments made for the upgrade nor will we refund any double
payments made for the same upgrade.
- We reserve the right to change the pricing of the upgrade at any time without prior notice.
- Please, feel free to contact us if you have any questions or concerns about your upgrade plans.

## 6. **Your Rights**

You have the right to access, update, or delete your personal information.
You can do this by contacting us via any of the contact information provided below.

## 7. **Changes to This Privacy Policy**

We may update this Privacy Policy from time to time. We will notify you of any
changes by posting the new Privacy Policy on this page. You are advised to review
this Privacy Policy periodically for any changes.

## **Contact Information**

For support or inquiries, please contact us at:
- Email: [$email](mailto:$email).
- Website: [https://atachiz02-softwares.b12sites.com/](https://atachiz02-softwares.b12sites.com/).
- LinkedIn: [Atachiz02 Softwares](https://www.linkedin.com/company/atachiz02softwares).

## **Last Updated**
- 20th October, 2024.
""";

  static String appInfo = """
# **Uriel Chat**

Uriel Chat is an innovative open source chat application that leverages
Google's Gemini Generative AI model to enhance your messaging experience.

## **Features**

- **Engage in Real-Time Conversations:** Get prompt AI response in real-time.
- **AI-Powered Responses:** Get intelligent responses from Uriel to keep the conversation going.
- **Customizable Settings:** Personalize your chat experience with various settings and preferences.
- **Secure and Private:** Your data is secure with us, and we prioritize your privacy.

## **App Info**

- **App Name:** Uriel Chat
- **Version:** 0.1.2-Beta
- **Developer:** Atachiz02 Softwares
""";

  static int free = 0, regular = 0, premium = 0, platinum = 0;
  static double regularMoney = 0, premiumMoney = 0, platinumMoney = 0;

  static List<String> mediaPlans = [];

  static String upgradePrompt = """
You have reached your daily chat limit. Upgrade to continue chatting.

# **Upgrade Options**

## **Free Plan (NGN 0.00) • 30 days**
- **Daily Limit:** $free messages
- **Features:**
  - Basic chat functionality
  - Fewer daily message limits

## **Regular Plan (NGN $regularMoney) • 30 days**
- **Daily Limit:** $regular messages
- **Features:**
  - Enhanced chat functionality
  - Priority support
  - Increased daily message limit

## **Premium Plan (NGN $premiumMoney) • 30 days**
- **Daily Limit:** $premium messages
- **Features:**
  - All Regular Tier features
  - Voice input chat support
  - Increased daily message limit

## **Platinum Plan (NGN $platinumMoney) • 30 days**
- **Daily Limit:** $platinum messages
- **Features:**
  - All Premium Tier features
  - Access to exclusive content
  - Image chat support

**Note:** Upgrading to a higher tier will reset your daily message count immediately.
""";
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}