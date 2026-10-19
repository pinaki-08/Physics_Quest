import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Records what a learner has done. Every write is keyed on the signed-in uid,
/// which is what the security rules match against, and fails silently so a
/// dropped connection never blocks a quiz.
class ProgressRepository {
  const ProgressRepository();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('progress').doc(uid);
  }

  Future<void> recordAttempt({
    required String quizId,
    required int score,
    required int total,
    required int points,
  }) async {
    final doc = _doc;
    if (doc == null) return;
    try {
      await doc.collection('attempts').add({
        'quizId': quizId,
        'score': score,
        'total': total,
        'points': points,
        'at': FieldValue.serverTimestamp(),
      });
      await doc.set({
        'points': FieldValue.increment(points),
        'attempts': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (error) {
      if (kDebugMode) debugPrint('Could not save attempt: $error');
    }
  }

  Future<int> totalPoints() async {
    final doc = _doc;
    if (doc == null) return 0;
    try {
      final snapshot = await doc.get();
      return (snapshot.data()?['points'] as num?)?.toInt() ?? 0;
    } catch (error) {
      if (kDebugMode) debugPrint('Could not read points: $error');
      return 0;
    }
  }
}

const progressRepository = ProgressRepository();
