import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../secrets.dart';        // emailJsServiceId, emailJsTemplateId, emailJsUserId
import 'pin_verify_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;

  // Send PIN email using EmailJS
  Future<int> _sendPinEmail(String email, String pin) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_id': emailJsServiceId,
        'template_id': emailJsTemplateId,
        'user_id': emailJsUserId,
        'template_params': {
          // these MUST match your EmailJS template variables:
          // To Email: {{user_email}}
          // Body:     {{passcode}} and {{time}}
          'user_email': email,   // -> {{user_email}}
          'passcode': pin,       // -> {{passcode}}
          'time': '2',          // -> {{time}} 
        },
      }),
    );

    // Optional debug:
    // print('EmailJS status: ${response.statusCode}');
    // print('EmailJS body: ${response.body}');

    return response.statusCode;
  }

  Future<void> _loginUser() async {
    setState(() => isLoading = true);

    try {
      // 1) Sign in with Firebase using the entered email/password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not found after login');

      // 2) Generate a 6-digit PIN
      final pin = (100000 + Random().nextInt(900000)).toString();

      // 3) Store PIN in Firestore against the user's UID
      await FirebaseFirestore.instance
          .collection('pins')
          .doc(user.uid)
          .set({
        'pin': pin,
        'timestamp': DateTime.now(),
        'email': user.email,
      });

      // 4) Send the PIN via EmailJS
      final status = await _sendPinEmail(user.email!, pin);

      if (status == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN sent to your email')),
        );
        // 5) Go to PIN verify screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PinVerifyScreen(uid: user.uid),
          ),
        );
      } else if (status != 200) {
        throw Exception(
          'Email sending failed (status $status). Check EmailJS params.',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login (Email + PIN)')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _loginUser,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
