import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'data/lesson_repository.dart';
import 'firebase_options.dart';
import 'home_screen.dart';
import 'services/firebase_boot.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final online = await bootFirebase(DefaultFirebaseOptions.currentPlatform);
  // The app must still work offline or before Firebase is provisioned, so
  // failing to connect downgrades to bundled content instead of crashing.
  lessonRepository =
      online ? const FirestoreLessonRepository() : const LocalLessonRepository();
  if (kDebugMode && !online) {
    debugPrint('Firebase unavailable - serving bundled lessons.');
  }
  runApp(const PhysicsQuestApp());
}

class PhysicsQuestApp extends StatelessWidget {
  const PhysicsQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Physics Quest',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
