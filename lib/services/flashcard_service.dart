import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/flashcard.dart';

/// Implements spaced repetition (SM2-like) review updates.
class FlashcardService {
  static final _fs = FirebaseFirestore.instance;

  /// Apply review rating (0-5). Returns updated card and persists to Firestore.
  static Future<Flashcard> reviewCard(Flashcard card, int rating) async {
    final now = DateTime.now();
    double ease = card.easeFactor;
    int reps = card.repetitions;
    int interval = card.intervalDays;

    // Bounds check rating.
    if (rating < 0) rating = 0; else if (rating > 5) rating = 5;

    if (rating < 3) {
      reps = 0;
      interval = 1;
    } else {
      reps += 1;
      if (reps == 1) {
        interval = 1;
      } else if (reps == 2) {
        interval = 6;
      } else {
        interval = (interval * ease).round();
      }
    }

    // Update ease factor per SM2 formula.
    ease = ease + (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));
    if (ease < 1.3) ease = 1.3;

    final updated = card.copyWith(
      repetitions: reps,
      easeFactor: double.parse(ease.toStringAsFixed(3)),
      intervalDays: interval,
      dueDate: now.add(Duration(days: interval)),
      lastRating: rating,
    );

    await _fs
        .collection('flashcard_decks')
        .doc(card.deckId)
        .collection('cards')
        .doc(card.id)
        .set(updated.toMap(), SetOptions(merge: true));

    return updated;
  }
}
