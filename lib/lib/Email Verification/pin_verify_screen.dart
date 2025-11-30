import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/email_pin_service.dart';

import '../../screens/home_screen_v3.dart';

class PinVerifyScreen extends StatefulWidget {
  final String uid;
  const PinVerifyScreen({super.key, required this.uid});

  @override
  State<PinVerifyScreen> createState() => _PinVerifyScreenState();
}

class _PinVerifyScreenState extends State<PinVerifyScreen> {
  final pinCtrl = TextEditingController();
  bool isVerifying = false;
  bool isResending = false;

  Future<void> _verifyPin() async {
    setState(() => isVerifying = true);

    final doc = await FirebaseFirestore.instance
      .collection('pins')
      .doc(widget.uid)
      .get();

    if (!doc.exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No PIN found, please login again')),
        );
        Navigator.pop(context);
      }
      setState(() => isVerifying = false);
      return;
    }

    final data = doc.data()!;
    final storedPin = data['pin'] as String;
    final timestamp = (data['timestamp'] as Timestamp).toDate();

    // Expire after 2 minutes
    if (DateTime.now().difference(timestamp).inMinutes >= 2) {
        await FirebaseFirestore.instance
          .collection('pins')
          .doc(widget.uid)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN expired, login again')),
        );
        Navigator.pop(context);
      }
      return;
    }

    if (pinCtrl.text.trim() == storedPin) {
      await FirebaseFirestore.instance
          .collection('pins')
          .doc(widget.uid)
          .delete();
      // Mark user verified in Firestore (create if missing)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .set({
            'isVerified': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreenV3()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid PIN')),
        );
      }
    }

    if (mounted) setState(() => isVerifying = false);
  }

  Future<void> _resendPin() async {
    setState(() => isResending = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('pins')
          .doc(widget.uid)
          .get();

      String? email;
      if (doc.exists) {
        final data = doc.data();
        email = data != null ? data['email'] as String? : null;
      }

      if (email == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No email found; please re-login')),
          );
        }
      } else {
        await EmailPinService().sendPin(widget.uid, email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PIN resent to $email')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend PIN: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify PIN')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter the 6-digit PIN sent to your email'),
            const SizedBox(height: 20),
            TextField(
              controller: pinCtrl,
              decoration: const InputDecoration(labelText: 'Enter PIN'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isVerifying ? null : _verifyPin,
              child: isVerifying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: isResending ? null : _resendPin,
              child: isResending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Resend PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
