import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/runtime_config.dart';
import '../utils/retry.dart';

/// GroqChatService provides a simple interface to call OpenAI's
/// chat completions endpoint.
class GroqChatService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  // Using GPT-4o-mini as default (fast and affordable)
  static const String _defaultModel = 'gpt-4o-mini';
  static const List<String> _fallbackModels = [
    // Fallback to GPT-3.5-turbo if needed
    'gpt-3.5-turbo',
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

  /// Summarize text using OpenAI API.
  /// Returns a concise summary of the provided text.
  static Future<String> summarizeText(String text, {int maxSummaryLength = 200}) async {
    if (text.trim().isEmpty) {
      throw Exception('Text cannot be empty');
    }

    // For very long text, chunk it first
    if (text.length > 12000) {
      final chunks = _chunkForLongDoc(text);
      final summaries = <String>[];
      for (final chunk in chunks) {
        final summary = await _summarizeChunk(chunk, maxSummaryLength ~/ chunks.length);
        summaries.add(summary);
      }
      // Combine and summarize again if needed
      final combined = summaries.join('\n');
      if (combined.length > maxSummaryLength * 2) {
        return await _summarizeChunk(combined, maxSummaryLength);
      }
      return combined;
    }

    return await _summarizeChunk(text, maxSummaryLength);
  }

  static Future<String> _summarizeChunk(String text, int maxLength) async {
    final prompt = '''Summarize the following text concisely in about $maxLength words. Focus on the key points and main ideas:

$text

Provide a clear, well-structured summary:''';
    
    return await sendMessage(
      prompt,
      systemPrompt: 'You are a helpful assistant that creates concise, accurate summaries. Focus on extracting key information and main ideas.',
      maxTokens: (maxLength * 2).clamp(100, 800),
      temperature: 0.5,
    );
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

    final prompt = '''You are a quiz generator. Using ONLY the content below, create ${numQuestions} high-quality multiple-choice questions.

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
- Exactly ${numQuestions} questions.
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
    
    // Strip markdown code blocks if present
    String cleaned = jsonText.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();
    
    print('📋 Quiz JSON Response (first 500 chars): ${cleaned.substring(0, cleaned.length > 500 ? 500 : cleaned.length)}');
    
    // Validate it's actually JSON
    try {
      jsonDecode(cleaned);
    } catch (e) {
      print('❌ Invalid JSON received from API: $e');
      throw Exception('API returned invalid JSON format. Please try again.');
    }
    
    return cleaned;
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

    final prompt = '''You are a flashcard generator. Using the content below, create ${numCards} high-quality flashcards.

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
- Create exactly ${numCards} flashcards.
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
    
    // Strip markdown code blocks if present
    String cleaned = jsonText.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    cleaned = cleaned.trim();
    
    print('📋 Flashcard JSON Response (first 500 chars): ${cleaned.substring(0, cleaned.length > 500 ? 500 : cleaned.length)}');
    
    // Validate it's actually JSON
    try {
      jsonDecode(cleaned);
    } catch (e) {
      print('❌ Invalid JSON received from API: $e');
      throw Exception('API returned invalid JSON format. Please try again.');
    }
    
    return cleaned;
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
      // Debug: Print API key info (first 10 chars only for security)
      final keyPreview = RuntimeConfig.groqApiKey.substring(0, 10);
      print('🔑 Using API key starting with: $keyPreview...');
      
      final resp = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${RuntimeConfig.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 60)); // Increased timeout for complex operations
      
      // Debug: Print response status
      print('📡 Groq API Response Status: ${resp.statusCode}');
      if (resp.statusCode != 200) {
        print('❌ Error Response Body: ${resp.body.substring(0, resp.body.length > 200 ? 200 : resp.body.length)}');
      }
      
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
      
      // Handle rate limiting with detailed message
      if (resp.statusCode == 429) {
        print('⚠️ Rate limit hit. Response: $errText');
        // Check if it's actually an invalid key masquerading as rate limit
        if (errText.toLowerCase().contains('invalid') || errText.toLowerCase().contains('authentication')) {
          throw Exception('Invalid API key. Please check your Groq API key at console.groq.com');
        }
        throw Exception('Rate limit exceeded. Please wait a few moments before trying again.');
      }
      
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        print('🔒 Authentication error. Key preview: ${RuntimeConfig.groqApiKey.substring(0, 15)}...');
        throw Exception('Invalid API key. Please verify your Groq API key at console.groq.com');
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