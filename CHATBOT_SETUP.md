# AlgoSonar AI Chatbot Setup Guide

## Overview
The AlgoSonar chatbot is a Flutter app that integrates with **Ollama**, a free, open-source language model framework. This allows you to run powerful AI conversations locally without any API costs.

## Prerequisites

### 1. Install Ollama
Ollama is required to run the language models. Download and install it from:
- **Website**: https://ollama.ai
- **Supported Platforms**: Windows, macOS, Linux

### 2. Install a Language Model
After installing Ollama, you need to download at least one language model. Popular options:

```bash
# Install Llama 2 (7B model - recommended for general use)
ollama pull llama2

# Other popular models
ollama pull mistral           # Mistral 7B (fast & good quality)
ollama pull neural-chat      # Neural Chat (optimized for chat)
ollama pull orca-mini        # Orca Mini (smaller, faster)
ollama pull dolphin-mixtral  # Dolphin Mixtral (very capable)
```

### 3. Run Ollama Server
Start the Ollama server (it runs on `http://localhost:11434` by default):

```bash
# On Windows, macOS
ollama serve

# The server will start listening at http://localhost:11434
```

## Setup Flutter App

### 1. Get Dependencies
```bash
cd algosonar
flutter pub get
```

### 2. Run the App
```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome

# For Windows/macOS/Linux
flutter run
```

## Using the Chatbot

### First Launch
1. Open the app
2. Check the connection status in the top-right corner:
   - **✓ Connected** (green) = Ollama is running and accessible
   - **✗ Disconnected** (red) = Ollama is not running

### Configuration
1. Tap the **Settings** (⚙️) icon
2. Configure:
   - **Ollama Server URL**: Default is `http://localhost:11434`
     - For remote server: Use the server's IP address (e.g., `http://192.168.1.100:11434`)
   - **Model**: Select from installed models
   - **System Prompt**: Customize AI behavior (e.g., "You are a Python expert helping students")

### Chat Features
- **Send Message**: Type and press Enter or tap the send button
- **Clear Chat**: Delete all messages (trash icon)
- **Refresh Connection**: Reconnect to Ollama server (refresh icon)
- **Typing Indicator**: Shows when the model is thinking

## Troubleshooting

### "Server is disconnected"
1. Check if Ollama is running:
   ```bash
   ollama serve
   ```
2. Verify the URL in Settings matches your Ollama server
3. Tap the refresh button to retry connection

### "No models available"
1. Ensure you've pulled at least one model:
   ```bash
   ollama list  # See installed models
   ollama pull llama2  # Install a model
   ```
2. Restart Ollama server

### Model takes too long to respond
- You may have a very large model or slow hardware
- Try a smaller model:
  ```bash
  ollama pull orca-mini
  ```

### App crashes when sending message
- Check Flutter console for error messages
- Update pubspec.yaml dependencies:
  ```bash
  flutter pub upgrade
  ```
- Run app with verbose logging:
  ```bash
  flutter run -v
  ```

## Remote Server Setup

To use Ollama from a remote server or different machine:

### On the Server (with Ollama)
1. Allow external connections:
   ```bash
   # On Windows/macOS/Linux, Ollama listens only on localhost by default
   # To allow remote connections, set OLLAMA_HOST environment variable:
   OLLAMA_HOST=0.0.0.0:11434 ollama serve
   ```

### On the Client (Flutter App)
1. Open Settings
2. Change Ollama Server URL to: `http://<SERVER_IP>:11434`
3. Save and refresh

## Model Recommendations

| Model | Size | Speed | Quality | Use Case |
|-------|------|-------|---------|----------|
| orca-mini | 1.3B | Very Fast | Good | Quick responses, limited device |
| mistral | 7B | Fast | Excellent | Best balance |
| llama2 | 7B | Medium | Good | General purpose |
| neural-chat | 7B | Medium | Excellent | Chat optimized |
| dolphin-mixtral | 45B | Slow | Excellent | Powerful, needs good GPU |

## API Features

### Ollama API Endpoints Used
- `GET /api/tags` - List available models
- `POST /api/generate` - Generate text (streaming & non-streaming)

### Response Time Estimates
- Small models (1-3B): 1-5 seconds per response
- Medium models (7B): 5-30 seconds per response
- Large models (30B+): 30+ seconds per response

*Response time depends on your hardware (GPU/CPU)*

## Development

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── screens/
│   └── chatbot_screen.dart   # Chatbot UI
├── services/
│   └── ollama_service.dart   # Ollama API integration
```

### Key Classes
- **OllamaService**: Handles Ollama API communication
- **ChatMessage**: Represents a message in chat history
- **ChatbotScreen**: Main UI for the chatbot

### Extending the App
1. Add more features by creating new screens
2. Add database support for persistent chat history:
   ```yaml
   dependencies:
     sqflite: ^2.0.0
   ```
3. Add voice input/output capabilities

## Security Notes
- Ollama runs locally by default (no data sent to external servers)
- When using remote servers, ensure proper network security
- Don't expose Ollama server to the public internet without authentication

## Advanced Configuration

### Custom System Prompts Examples
```
"You are a Python programming tutor. Explain concepts step by step."

"You are a helpful medical information assistant. Always suggest consulting a doctor."

"You are a creative writing assistant. Help users brainstorm and improve their stories."
```

### Performance Tuning
- Reduce model context if getting out-of-memory errors
- Use smaller models for resource-constrained devices
- Enable GPU acceleration in Ollama for faster responses

## Support & Resources
- Ollama GitHub: https://github.com/ollama/ollama
- Ollama Models: https://ollama.ai/library
- Flutter Documentation: https://flutter.dev/docs
