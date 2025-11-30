import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class EmailPinService {
  Future<void> sendPin(String uid, String email) async {
    if (email.trim().isEmpty) {
      throw Exception('Recipient email is empty');
    }
    final pin = (100000 + Random().nextInt(900000)).toString();

    // Save pin + timestamp keyed by UID
    final now = DateTime.now();
    await FirebaseFirestore.instance.collection('pins').doc(uid).set({
      'pin': pin,
      'timestamp': now,
      'email': email,
    });

    // Send Email via EmailJS
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': emailJsServiceId,
        'template_id': emailJsTemplateId,
        'user_id': emailJsUserId,
        // Required if EmailJS account is in strict mode (private key / access token)
        'accessToken': emailJsPrivateKey,
        'template_params': {
          // Provide multiple common variable names to be compatible with template
          // Ensure EmailJS template "To" field uses one of: {{to_email}} | {{user_email}} | {{to}}
          'to_email': email,
          'user_email': email,
          'to': email,
          // Include both 'message' and 'pin' for template body flexibility
          'message': pin,
          'pin': pin,
          // Align with template fields shown in screenshot
          'passcode': pin,
          'time': 2, // minutes until expiry, used as {{time}}
          'subject': 'Your verification code',
          'from_name': 'Muallim',
        },
      }),
    );

    // Basic logging for debugging deliverability issues
    // You can surface these in UI via SnackBars where needed
    if (response.statusCode == 200) {
      // EmailJS accepted the request
      // print('EmailJS: PIN email accepted. Body: ${response.body}');
      return;
    } else {
      final body = response.body;
      // print('EmailJS error: status ${response.statusCode}, body: $body');
      throw Exception('Failed to send verification email (status ${response.statusCode}): $body');
    }
  }
}