import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey;
  late GenerativeModel _model;

  GeminiService({required this.apiKey}) {
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  /// Send a message and get a response from Gemini
  Future<String> chat(String message, String? systemPrompt) async {
    try {
      final prompt = systemPrompt != null
          ? '$systemPrompt\n\n$message'
          : message;
      final content = [Content.text(prompt)];

      final response = await _model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      }

      return 'No response from Gemini API';
    } catch (e) {
      throw Exception('Error communicating with Gemini: $e');
    }
  }

  /// Stream messages from Gemini
  Stream<String> chatStream(String message, String? systemPrompt) async* {
    try {
      final prompt = systemPrompt != null
          ? '$systemPrompt\n\n$message'
          : message;
      final content = [Content.text(prompt)];

      final stream = _model.generateContentStream(content);

      await for (final response in stream) {
        if (response.text != null && response.text!.isNotEmpty) {
          yield response.text!;
        }
      }
    } catch (e) {
      // If streaming fails, try non-streaming as fallback
      try {
        final result = await chat(message, systemPrompt);
        yield result;
      } catch (fallbackError) {
        throw Exception(
          'Error with Gemini: $e (Fallback also failed: $fallbackError)',
        );
      }
    }
  }

  /// Check if the API key is valid by making a test request
  Future<bool> isApiKeyValid() async {
    try {
      final content = [Content.text('test')];

      final response = await _model.generateContent(content);
      return response.text != null && response.text!.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Message model for chat history
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  @override
  String toString() =>
      'ChatMessage(id: $id, content: $content, isUser: $isUser, timestamp: $timestamp)';
}
