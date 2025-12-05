import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A compact badge that displays the user's total XP from Firestore.
/// Usage:
///   XpBadge()
class XpBadge extends StatelessWidget {
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final Widget? leading;
  final String label;

  const XpBadge({
    super.key,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.leading,
    this.label = 'Total XP',
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _buildChip(context, 0);
    }
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: doc.snapshots(),
      builder: (context, snap) {
        int xp = 0;
        if (snap.hasData && snap.data?.data() != null) {
          final data = snap.data!.data()!;
          xp = (data['xp'] as int?) ?? 0;
        }
        return _buildChip(context, xp);
      },
    );
  }

  Widget _buildChip(BuildContext context, int xp) {
    final style = textStyle ?? Theme.of(context).textTheme.titleMedium;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) leading! else Icon(Icons.bolt, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).hintColor)),
              Text(xp.toString(), style: style),
            ],
          ),
        ],
      ),
    );
  }
}
