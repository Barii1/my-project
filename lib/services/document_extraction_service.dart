import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/runtime_config.dart';

/// Provides text extraction for PDFs and images.
/// Uses Syncfusion PDF for parsing and Google ML Kit for OCR.
/// NOTE: ML Kit OCR works on mobile platforms (Android/iOS); for web/desktop returns fallback.
class DocumentExtractionService {
  static Future<String> extractTextFromPdf(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final buffer = StringBuffer();
      final extractor = PdfTextExtractor(document);
      for (int i = 0; i < document.pages.count; i++) {
        final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        buffer.write(pageText);
        buffer.write('\n');
      }
      document.dispose();
      final text = buffer.toString().trim();
      return text.isEmpty ? 'No extractable text found in PDF.' : text;
    } catch (e) {
      return 'Failed to extract PDF text: $e';
    }
  }

  static Future<String> extractTextFromImage(File imageFile) async {
    // Fallback for non-mobile platforms
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      // Use Cloud Function fallback.
      try {
        final bytes = await imageFile.readAsBytes();
        final base64Img = base64Encode(bytes);
        final url = '${RuntimeConfig.functionsBaseUrl}/ocrImage';
        final resp = await http.post(Uri.parse(url), headers: {
          'Content-Type': 'application/json'
        }, body: jsonEncode({'imageBase64': base64Img}));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          final text = (data['text'] ?? '').toString().trim();
          return text.isEmpty ? 'No text detected in image.' : text;
        }
        return 'Remote OCR failed (${resp.statusCode}).';
      } catch (e) {
        return 'Remote OCR error: $e';
      }
    }
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizer = TextRecognizer();
      final result = await recognizer.processImage(inputImage);
      await recognizer.close();
      final text = result.text.trim();
      return text.isEmpty ? 'No text detected in image.' : text;
    } catch (e) {
      return 'Failed to perform OCR: $e';
    }
  }

  /// Splits long extracted text into manageable chunks to keep prompts under limits.
  static List<String> chunkText(String text, {int maxChunkChars = 8000}) {
    final cleaned = text.replaceAll('\r', '').trim();
    if (cleaned.length <= maxChunkChars) return [cleaned];
    final List<String> chunks = [];
    int start = 0;
    while (start < cleaned.length) {
      int end = start + maxChunkChars;
      if (end >= cleaned.length) {
        chunks.add(cleaned.substring(start));
        break;
      }
      // Try to break at a sentence boundary near the end.
      int breakIndex = cleaned.lastIndexOf('.', end);
      if (breakIndex < start + (maxChunkChars * 0.6)) {
        breakIndex = end; // fallback, no good boundary
      }
      chunks.add(cleaned.substring(start, breakIndex + 1));
      start = breakIndex + 1;
    }
    return chunks.map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
  }
}
