import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  Future<bool> _requestPermissionFor(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      // For gallery: handle Android 13 vs older platforms
      if (Platform.isAndroid) {
        final status = await Permission.photos.request(); // maps to READ_MEDIA_IMAGES on Android 13+
        return status.isGranted;
      } else {
        final status = await Permission.photos.request();
        return status.isGranted;
      }
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final granted = await _requestPermissionFor(source);
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied. Enable in settings.')),
      );
      return;
    }

    try {
      setState(() => _loading = true);
      final pickedFile = await _picker.pickImage(source: source, maxWidth: 2048);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      final filePath = 'users/$uid/images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storage = StorageService();
      final url = await storage.uploadImage(_image!, filePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded: $url')),
      );
      developer.log('Uploaded image url: $url');
      // Optionally: save URL to Firestore via your DatabaseService here.
    } catch (e) {
      developer.log('Upload failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              width: 300,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : const Center(child: Text("No image selected")),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
                ElevatedButton.icon(
                  onPressed: () => pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_image != null)
              ElevatedButton(
                onPressed: _uploadImage,
                child: const Text('Use this image'),
              ),
            if (_image != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => _image = null),
              ),
          ],
        ),
      ),
    );
  }
}

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snap = await uploadTask;
    final url = await snap.ref.getDownloadURL();
    return url;
  }
}

