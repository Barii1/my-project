import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../providers/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// stats_provider removed for XP display; now using Firestore stream
import 'settings/appearance_settings_screen.dart';
import 'settings/notifications_settings_screen.dart';
import 'settings/help_faq_screen.dart';
import 'settings/feedback_screen.dart';
import 'settings/profile_settings_screen.dart';
import 'settings/data_usage_screen.dart';
import 'settings/security_settings_screen.dart';
import 'settings/delete_account_screen.dart';
import 'settings/app_usage_screen.dart';

class SettingsScreenModern extends StatefulWidget {
  final Map<String, String> user;
  final VoidCallback onLogout;

  const SettingsScreenModern({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<SettingsScreenModern> createState() => _SettingsScreenModernState();
}

class _SettingsScreenModernState extends State<SettingsScreenModern> {
  String? _profileImageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.photoURL != null) {
      setState(() {
        _profileImageUrl = user!.photoURL;
      });
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');
      
      final uploadTask = storageRef.putFile(File(pickedFile.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user profile
      await user.updatePhotoURL(downloadUrl);

      setState(() {
        _profileImageUrl = downloadUrl;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 96),
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildProfileCard(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Preferences'),
            _buildSettingsGroup(context, [
              Builder(
                builder: (context) {
                  final themeProvider = Provider.of<ThemeProvider>(context);
                  String themeText;
                  switch (themeProvider.themeMode) {
                    case ThemeMode.light:
                      themeText = 'Light Mode';
                      break;
                    case ThemeMode.dark:
                      themeText = 'Dark Mode';
                      break;
                    case ThemeMode.system:
                      themeText = 'System Default';
                      break;
                  }
                  return _buildSettingsItem(
                    context,
                    icon: Icons.palette_outlined,
                    iconColor: const Color(0xFF9B59B6),
                    title: 'Appearance',
                    subtitle: themeText,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AppearanceSettingsScreen()));
                    },
                  );
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFF3498DB),
                title: 'Notifications',
                subtitle: 'Enabled',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const NotificationsSettingsScreen()));
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.data_usage,
                iconColor: const Color(0xFF2ECC71),
                title: 'Data Usage',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DataUsageScreen()));
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.av_timer,
                iconColor: const Color(0xFF9B59B6),
                title: 'Screen Time',
                subtitle: 'Track your study habits',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AppUsageScreen()));
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Support'),
            _buildSettingsGroup(context, [
              _buildSettingsItem(
                context,
                icon: Icons.help_outline,
                iconColor: const Color(0xFFE67E22),
                title: 'Help & FAQ',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelpFaqScreen()));
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.feedback_outlined,
                iconColor: const Color(0xFFE74C3C),
                title: 'Send Feedback',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FeedbackScreen()));
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Account'),
            _buildSettingsGroup(context, [
              _buildSettingsItem(
                context,
                icon: Icons.security_outlined,
                iconColor: const Color(0xFF34495E),
                title: 'Security',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SecuritySettingsScreen()));
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.delete_outline,
                iconColor: const Color(0xFFC0392B),
                title: 'Delete Account',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DeleteAccountScreen()));
                },
              ),
            ]),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Text(
      'Settings',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF34495E),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFFFE6ED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _isUploadingImage ? null : _pickAndUploadProfileImage,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4DB8A8), Color(0xFF3DA89A)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4DB8A8).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.transparent,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _isUploadingImage
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : _profileImageUrl == null
                                ? Text(
                                    (widget.user['name'] ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                      ),
                    ),
                    if (!_isUploadingImage)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4DB8A8),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user['name'] ?? 'User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF34495E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user['email'] ?? 'user@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileSettingsScreen()));
                },
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF3DA89A)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1F2937), const Color(0xFF1A1A2E)]
                    : [const Color(0xFFFEF7FA), const Color(0xFFF9FAFB)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4DB8A8).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB8A8).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: Color(0xFF4DB8A8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total Points',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Builder(builder: (context) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        return Text(
                          '0 XP',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF34495E),
                            letterSpacing: 0.5,
                          ),
                        );
                      }
                      final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
                      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: doc.snapshots(),
                        builder: (context, snap) {
                          int xp = 0;
                          if (snap.hasData && snap.data?.data() != null) {
                            xp = (snap.data!.data()!['xp'] as int?) ?? 0;
                          }
                          return Text(
                            '$xp XP',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF34495E),
                              letterSpacing: 0.5,
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFFFE6ED)),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF34495E),
                      ),
                    );
                  },
                ),
              ),
              if (subtitle != null)
                Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white70 : const Color(0xFF9CA3AF),
                      ),
                    );
                  },
                ),
              const SizedBox(width: 8),
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Icon(Icons.chevron_right, color: isDark ? Colors.white54 : const Color(0xFF9CA3AF));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFE53E3E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onLogout,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
