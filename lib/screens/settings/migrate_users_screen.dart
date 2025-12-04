import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// One-time migration helper to add searchName field to existing users
/// 
/// USAGE:
/// 1. Add a button in your settings/admin screen:
///    ElevatedButton(
///      onPressed: () => Navigator.push(context, 
///        MaterialPageRoute(builder: (_) => MigrateUsersScreen())),
///      child: Text('Migrate Users (One-time)'),
///    )
/// 
/// 2. Run once to update all existing users
/// 3. Remove this screen after migration is complete
class MigrateUsersScreen extends StatefulWidget {
  const MigrateUsersScreen({super.key});

  @override
  State<MigrateUsersScreen> createState() => _MigrateUsersScreenState();
}

class _MigrateUsersScreenState extends State<MigrateUsersScreen> {
  bool _isMigrating = false;
  String _status = 'Ready to migrate existing users';
  int _updatedCount = 0;
  int _totalCount = 0;

  Future<void> _migrateUsers() async {
    setState(() {
      _isMigrating = true;
      _status = 'Fetching users from Firestore...';
      _updatedCount = 0;
      _totalCount = 0;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final usersSnapshot = await firestore.collection('users').get();
      
      setState(() {
        _totalCount = usersSnapshot.docs.length;
        _status = 'Found $_totalCount users. Adding searchName field...';
      });

      final batch = firestore.batch();
      int count = 0;

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        
        // Only update if searchName is missing
        if (data['fullName'] != null && data['searchName'] == null) {
          batch.update(doc.reference, {
            'searchName': (data['fullName'] as String).toLowerCase(),
          });
          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
        setState(() {
          _updatedCount = count;
          _status = 'Success! Updated $count users with searchName field.';
          _isMigrating = false;
        });
      } else {
        setState(() {
          _status = 'All users already have searchName field. No updates needed.';
          _isMigrating = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isMigrating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFEF7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF34495E),
        elevation: 1,
        title: const Text('Migrate Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF4DB8A8), size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Migration Info',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4DB8A8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This will add the searchName field to all existing users in your Firestore database.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The searchName field enables case-insensitive user search.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Warning: Only run this ONCE for existing users.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF59E0B),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A2E45) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF34495E),
                    ),
                  ),
                  if (_totalCount > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Users',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_totalCount',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF34495E),
                              ),
                            ),
                          ],
                        ),
                        if (_updatedCount > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Updated',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF4DB8A8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_updatedCount',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4DB8A8),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_isMigrating)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF4DB8A8)),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4DB8A8),
                      ),
                    ),
                  ],
                ),
              )
            else
              ElevatedButton(
                onPressed: _migrateUsers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DB8A8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Run Migration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
