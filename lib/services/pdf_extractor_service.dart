import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfExtractorService {
  /// Extracts text from the first up to 30 pages and truncates to ~15k chars.
  static String extractText(String pdfPath) {
    final bytes = File(pdfPath).readAsBytesSync();
    final doc = PdfDocument(inputBytes: bytes);
    final buffer = StringBuffer();
    final maxPages = doc.pages.count > 30 ? 30 : doc.pages.count;
    final extractor = PdfTextExtractor(doc);
    for (int i = 0; i < maxPages; i++) {
      buffer.write(extractor.extractText(startPageIndex: i, endPageIndex: i));
      buffer.write('\n');
    }
    doc.dispose();
    var extracted = buffer.toString();
    if (extracted.isEmpty) return 'No text extracted from PDF';
    if (extracted.length > 15000) {
      extracted = extracted.substring(0, 15000) + '\n\n[Note: PDF truncated to first 15,000 characters due to size]';
    }
    return extracted;
  }
}