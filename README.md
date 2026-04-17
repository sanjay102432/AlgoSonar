# AlgoSonar

A Flutter application that provides stock analysis and AI-powered chatbot assistance using Google's Gemini API.

## Features

- **Market Analysis**: Real-time stock market data and analysis
- **AI Chatbot**: Intelligent assistant powered by Google Gemini API
- **World Monitor**: Global market and economic monitoring
- **Cross-platform**: Available on Android, iOS, Web, Windows, macOS, and Linux

## Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK 3.0 or higher
- Google Gemini API Key

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/algosonar.git
cd algosonar
```

### 2. Setup Gemini API Key

#### Step 1: Get Your Gemini API Key

1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Click on **"Create API key"** button
3. Select the project you want to use (or create a new one)
4. Your API key will be generated automatically
5. Copy the API key

#### Step 2: Configure the API Key in the App

The app uses a TextEditingController to accept the Gemini API key. You have two options:

**Option A: Interactive Input (Recommended for Development)**
- Launch the app
- Go to the Chatbot screen
- Enter your Gemini API key in the input field
- Click the refresh button to validate the connection

**Option B: Manual Configuration (For Testing)**
- Open `lib/screens/chatbot_screen.dart`
- Find line 26 with `final TextEditingController _apiKeyController = TextEditingController(`
- Replace the `text:` value with your API key:
  ```dart
  final TextEditingController _apiKeyController = TextEditingController(
    text: 'YOUR_GEMINI_API_KEY_HERE',
  );
  ```
- **NOTE**: Do NOT commit this change to git. Always use Option A for production deployments.

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the Application

```bash
# For development
flutter run

# For specific platform
flutter run -d windows    # Windows
flutter run -d macos      # macOS
flutter run -d linux      # Linux
flutter run -d chrome     # Web
```

## Security Notice

⚠️ **IMPORTANT**: Never commit your Gemini API key to version control:
- The `.gitignore` file is configured to ignore `.env` and similar files
- Always use the provided `.env.example` as a template for local configuration
- Keep your API key private and secure
- If you accidentally commit a key, regenerate it immediately from Google AI Studio

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/
│   ├── chatbot_screen.dart  # AI chatbot interface
│   ├── home_screen.dart     # Home screen
│   ├── market_analysis_screen.dart  # Market analysis
│   └── worldmonitor_screen.dart     # World monitoring
├── services/
│   └── gemini_service.dart  # Gemini API integration
└── theme/
    └── colors.dart          # App color scheme
```

## API Integration

### Gemini Service

The app uses `GeminiService` to handle all Gemini API interactions:

```dart
// Initialize the service with your API key
final geminiService = GeminiService(apiKey: 'YOUR_API_KEY');

// Send a message and get a response
final response = await geminiService.chat(message, systemPrompt);

// Use streaming for better UX
geminiService.chatStream(message, systemPrompt).listen((chunk) {
  print(chunk);
});

// Validate API key
final isValid = await geminiService.isApiKeyValid();
```

## Troubleshooting

### "Error initializing Gemini"
- Verify your API key is correct
- Check your internet connection
- Ensure the API key has appropriate permissions in Google Cloud Console

### "No response from Gemini API"
- Check if your API quota is exceeded
- Verify your network connectivity
- Try again after a few seconds

### "Disconnected" Status
- Click the refresh button in the app's chatbot screen
- Check your internet connection
- Verify your API key is still valid

## Building for Production

```bash
# Android
flutter build apk
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web

# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Google Generative AI SDK](https://pub.dev/packages/google_generative_ai)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [Google AI Studio](https://aistudio.google.com/)

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review existing GitHub issues
3. Create a new issue with detailed information
