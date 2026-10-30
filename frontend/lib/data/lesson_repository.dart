import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/lesson.dart';
import 'forces_content.dart';
import 'gravity_content.dart';
import 'machines_content.dart';
import 'motion_content.dart';

abstract class LessonRepository {
  Future<Lesson> fetch(String id);
  Future<List<Lesson>> fetchAll();
}

/// Chosen at startup: Firestore when Firebase is reachable, bundled otherwise.
LessonRepository lessonRepository = const LocalLessonRepository();

/// Serves lessons compiled into the app, as an offline fallback.
class LocalLessonRepository implements LessonRepository {
  const LocalLessonRepository();

  static final _lessons = <String, Lesson>{
    'motion': motionLesson,
    'forces': forcesLesson,
    'gravity': gravityLesson,
    'machines': machinesLesson,
  };

  @override
  Future<Lesson> fetch(String id) async {
    final lesson = _lessons[id];
    if (lesson == null) throw ArgumentError('Unknown lesson: $id');
    return lesson;
  }

  @override
  Future<List<Lesson>> fetchAll() async => _lessons.values.toList();
}

class FirestoreLessonRepository implements LessonRepository {
  const FirestoreLessonRepository();

  @override
  Future<Lesson> fetch(String id) async {
    final local = await const LocalLessonRepository().fetch(id);
    final doc = await FirebaseFirestore.instance
        .collection('lessons')
        .doc(id)
        .get();
    final data = doc.data();
    if (data == null) return local;
    return Lesson.fromJson(data).withTranslationFallback(local);
  }

  @override
  Future<List<Lesson>> fetchAll() async {
    final local = await const LocalLessonRepository().fetchAll();
    final localById = {for (final lesson in local) lesson.id: lesson};
    final snapshot = await FirebaseFirestore.instance
        .collection('lessons')
        .orderBy('order')
        .get();
    if (snapshot.docs.isEmpty) return local;
    return snapshot.docs.map((document) {
      final lesson = Lesson.fromJson(document.data());
      final fallback = localById[lesson.id];
      return fallback == null
          ? lesson
          : lesson.withTranslationFallback(fallback);
    }).toList();
  }
}
