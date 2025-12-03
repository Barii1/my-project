import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/runtime_config.dart';
import '../utils/retry.dart';

/// GroqChatService provides a simple interface to call Groq's
/// OpenAI-compatible chat completions endpoint.
class GroqChatService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  // Recommended Groq model (adjustable):
  // Use versatile by default per user request.
  static const String _defaultModel = 'llama-3.1-70b-versatile';
  static const List<String> _fallbackModels = [
    // Keep same family smaller instant first for capacity, then versatile again as last resort.
    'llama-3.1-8b-instant',
  ];

  /// Sends a single-turn user prompt and returns the assistant reply.
  static Future<String> sendMessage(String userMessage, {String? systemPrompt, String? model, int maxTokens = 512, double temperature = 0.7}) async {
    final chosenModel = model ?? _defaultModel;
    final messages = <Map<String, String>>[];
    if (systemPrompt != null && systemPrompt.trim().isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }
    messages.add({'role': 'user', 'content': userMessage});

    final resp = await _callWithModelFallback({
      'messages': messages,
      'max_tokens': maxTokens,
      'temperature': temperature,
      'stream': false,
    }, chosenModel);
    return resp;
  }

  /// Multi-turn conversation: pass a history list of role/content maps.
  /// Example history element: {'role': 'user', 'content': 'Hello'}
  static Future<String> sendConversation(List<Map<String, String>> history, {String? model, int maxTokens = 512, double temperature = 0.7}) async {
    final chosenModel = model ?? _defaultModel;
    final resp = await _callWithModelFallback({
      'messages': history,
      'max_tokens': maxTokens,
      'temperature': temperature,
      'stream': false,
    }, chosenModel);
    return resp;
  }

  /// Document Q&A helper: provide extracted text + a question.
  static Future<String> askAboutDocument(String extractedText, String question) {
    // If very long, summarize chunks first.
    if (extractedText.length > 12000) {
      return _askAboutLongDocument(extractedText, question);
    }
    final prompt = 'You are a tutor. Use the document below to answer concisely.\n\nDocument:\n$extractedText\n\nQuestion: $question';
    return sendMessage(prompt, systemPrompt: 'Answer using only the document if possible.', maxTokens: 800);
  }

  static Future<String> _askAboutLongDocument(String extractedText, String question) async {
    // Summarize chunks first to stay within context limits.
    List<String> chunks = _chunkForLongDoc(extractedText);
    final summaries = <String>[];
    for (final chunk in chunks) {
      final summaryPrompt = 'Summarize this chunk focusing on facts relevant to the final question: "$question"\n\nChunk:\n$chunk';
      final summary = await sendMessage(summaryPrompt, systemPrompt: 'You are condensing educational material. Output concise bullet points.');
      summaries.add(summary);
    }
    final combined = summaries.join('\n');
    final finalPrompt = 'Using ONLY the consolidated bullet points below, answer the user question.\n\nBullet Points:\n$combined\n\nQuestion: $question';
    return sendMessage(finalPrompt, systemPrompt: 'Provide a concise, well-structured answer using bullet points if suitable.');
  }

  /// Generate multiple-choice quiz questions from a document.
  /// Returns a JSON string containing an array of questions with options and explanations.
  static Future<String> generateQuizFromDocument(String extractedText, {int numQuestions = 5}) async {
    // Limit very large docs with chunking summaries first
    String source = extractedText;
    if (extractedText.length > 12000) {
      final chunks = _chunkForLongDoc(extractedText);
      final summaries = <String>[];
      for (final chunk in chunks) {
        final summary = await sendMessage(
          'Summarize key factual points suitable for building quiz questions from this educational content.\n\n$chunk',
          systemPrompt: 'You condense content into concise, quiz-focused bullet points.',
          maxTokens: 500,
        );
        summaries.add(summary);
      }
      source = summaries.join('\n');
    }

    final prompt = '''You are a quiz generator. Using ONLY the content below, create $numQuestions high-quality multiple-choice questions.

Content:
$source

Output STRICTLY as JSON with this schema:
[
  {
    "stem": "Question text",
    "options": [
      {"text": "Option A", "correct": false},
      {"text": "Option B", "correct": true},
      {"text": "Option C", "correct": false},
      {"text": "Option D", "correct": false}
    ],
    "explanation": "Short explanation referencing the content"
  }
]

Rules:
- Exactly $numQuestions questions.
- Exactly 4 options per question.
- Mark exactly one option as correct.
- Keep stems concise and unambiguous.
- Base every question on the provided content; do not invent facts.
- Return ONLY valid JSON, no markdown, no comments.''';

    final jsonText = await sendMessage(
      prompt,
      systemPrompt: 'You produce strict JSON only. No extra text.',
      maxTokens: 1200,
      temperature: 0.3,
    );
    return jsonText;
  }

  /// Generate flashcards from document content.
  /// Returns JSON string with question/answer pairs.
  static Future<String> generateFlashcardsFromDocument(String extractedText, {int numCards = 10}) async {
    String source = extractedText;
    if (extractedText.length > 12000) {
      final chunks = _chunkForLongDoc(extractedText);
      final summaries = <String>[];
      for (final chunk in chunks) {
        final summary = await sendMessage(
          'Summarize key concepts from this content for creating flashcards.\n\n$chunk',
          systemPrompt: 'You condense educational content into flashcard-ready concepts.',
          maxTokens: 500,
        );
        summaries.add(summary);
      }
      source = summaries.join('\n');
    }

    final prompt = '''You are a flashcard generator. Using the content below, create $numCards high-quality flashcards.

Content:
$source

Output STRICTLY as JSON with this schema:
[
  {
    "question": "Question text",
    "answer": "Answer text"
  }
]

Rules:
- Create exactly $numCards flashcards.
- Questions should be clear and concise.
- Answers should be accurate and complete.
- Base flashcards on the provided content.
- Return ONLY valid JSON, no markdown, no comments.''';

    final jsonText = await sendMessage(
      prompt,
      systemPrompt: 'You produce strict JSON only. No extra text.',
      maxTokens: 1500,
      temperature: 0.3,
    );
    return jsonText;
  }

  static List<String> _chunkForLongDoc(String text, {int size = 6000}) {
    final cleaned = text.replaceAll('\r', '').trim();
    if (cleaned.length <= size) return [cleaned];
    final chunks = <String>[];
    int start = 0;
    while (start < cleaned.length) {
      int end = start + size;
      if (end >= cleaned.length) {
        chunks.add(cleaned.substring(start));
        break;
      }
      // Try to break at sentence end
      int breakIndex = cleaned.lastIndexOf('.', end);
      if (breakIndex < start + (size * 0.5)) {
        breakIndex = cleaned.lastIndexOf(' ', end);
      }
      if (breakIndex < start + (size * 0.5)) breakIndex = end;
      chunks.add(cleaned.substring(start, breakIndex + 1));
      start = breakIndex + 1;
    }
    return chunks.map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
  }

  /// Internal POST with retry/backoff.
  static Future<http.Response> _postWithRetry(Map<String, dynamic> body) {
    return retry(() async {
      final resp = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${RuntimeConfig.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 60)); // Increased timeout for complex operations
      if (resp.statusCode >= 500) {
        // Retry on server errors.
        throw Exception('Server error ${resp.statusCode}');
      }
      // Don't retry on rate limits - let them fail immediately
      if (resp.statusCode == 429) {
        return resp;
      }
      return resp;
    });
  }

  static String _extractContent(String body) {
    final data = jsonDecode(body);
    final content = data['choices']?[0]?['message']?['content'];
    if (content is String) return content.trim();
    throw Exception('Malformed response: $body');
  }

  static String _extractError(String body) {
    try {
      final data = jsonDecode(body);
      final err = data['error'] ?? data['message'] ?? data.toString();
      return err.toString();
    } catch (_) {
      return body;
    }
  }

  static Future<String> _callWithModelFallback(Map<String, dynamic> baseBody, String model) async {
    final tryModels = [model, ..._fallbackModels];
    for (int i = 0; i < tryModels.length; i++) {
      final m = tryModels[i];
      final resp = await _postWithRetry({
        'model': m,
        ...baseBody,
      });
      if (resp.statusCode == 200) {
        return _extractContent(resp.body);
      }

      final errText = _extractError(resp.body);
      
      // Handle rate limiting
      if (resp.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please wait a few moments before trying again.');
      }
      
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        throw Exception('Unauthorized with Groq. Check GROQ_API_KEY via --dart-define or secrets.dart.');
      }
      
      if (resp.statusCode == 400 && errText.toLowerCase().contains('model')) {
        // Try next fallback model
        if (i < tryModels.length - 1) continue;
      }
      
      // Provide more helpful error messages
      if (resp.statusCode == 503) {
        throw Exception('Service temporarily unavailable. Please try again in a moment.');
      }
      
      throw Exception('Groq API error (${resp.statusCode}): $errText');
    }
    throw Exception('No valid Groq model available.');
  }
}

/*
USAGE EXAMPLES (call from your UI or a Provider):

// Single message
final reply = await GroqChatService.sendMessage('Explain photosynthesis in simple terms');

// With system prompt & custom model
final reply2 = await GroqChatService.sendMessage(
  'Summarize the following in bullet points: ...',
  systemPrompt: 'You are a helpful science tutor.',
  model: 'llama-3.1-70b-instant',
  maxTokens: 300,
);

// Multi-turn conversation
final conversationReply = await GroqChatService.sendConversation([
  {'role': 'system', 'content': 'You are a friendly math tutor.'},
  {'role': 'user', 'content': 'What is the derivative of x^2?'}
]);

// Document Q&A (after extracting text from PDF or OCR from image)
final answer = await GroqChatService.askAboutDocument(extractedText, 'What are the key steps mentioned?');

SECURITY NOTE:
The API key is currently in secrets.dart. For production:
 - Move it to .env using flutter_dotenv, or
 - Fetch from secure backend / remote config, or
 - Use platform secure storage and inject at runtime.
Do not commit real keys to public repositories.
*/