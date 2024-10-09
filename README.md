# Uriel Chat

Uriel Chat is a Generative AI mobile application that allows users to interact with an AI model to ask questions and receive responses.
The app is powered by Google's Gemini AI and developed by Atachiz02 Softwares.

## Features

- **Generative AI Chat**: Interact with an AI model to ask questions and receive responses.
- **Customizable UI**: The app features a modern and customizable user interface.
- **Chat History**: View and manage your chat history.
- **Clipboard Integration**: Copy chat messages to the clipboard.
- **Voice and Camera Input**: Use voice and camera input for a more interactive experience.

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.5.3 or higher)
- [Dart](https://dart.dev/get-dart) (version 2.18.0 or higher)
- [Android Studio](https://developer.android.com/studio)
  or [Visual Studio Code](https://code.visualstudio.com/)

### Installation

1. **Clone the repository**:
    ```sh
    git clone https://github.com/Atachiz02Softwares/UrielChat.git
    cd UrielChat
    ```

2. **Install dependencies**:
    ```sh
    flutter pub get
    ```

3. **Set up environment variables**:
    - Create a `.env` file in the root directory.
    - Add your Google API key:
      ```env
      GOOGLE_API_KEY=your_api_key_here
      ```

4. **Run the app**:
    ```sh
    flutter run
    ```

## Project Structure

- `lib/`: Contains the main source code for the Flutter app.
    - `screens/`: Contains the different screens of the app.
        - `chat_screen.dart`: The main chat screen where users interact with the AI.
        - `home_screen.dart`: The home screen of the app.
    - `custom_widgets/`: Contains custom widgets used throughout the app.
    - `utils/`: Contains utility functions and classes.
    - `strings.dart`: Contains string constants used in the app.

## Dependencies

The app uses the following dependencies:

- `flutter`: The Flutter framework.
- `cupertino_icons`: Icons for iOS style.
- `smooth_page_indicator`: Smooth page indicators.
- `flutter_svg`: SVG rendering.
- `flutter_dotenv`: Load environment variables from a `.env` file.
- `flutter_gradient_colors`: Gradient colors for Flutter.
- `google_generative_ai`: Google Generative AI API.
- `google_fonts`: Google Fonts for Flutter.
- `flutter_markdown`: Render Markdown in Flutter.
- `intl`: Internationalization and localization.

## License

This project is licensed under the MIT License—see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Google Generative AI](https://aistudio.google.com/)
- [Google Fonts](https://fonts.google.com/)
- [Markdown](https://daringfireball.net/projects/markdown/)

For more information, visit the [official documentation](https://docs.flutter.dev/).
