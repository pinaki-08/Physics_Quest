import 'dart:convert';
import 'dart:io';

import 'package:physics_quest/data/forces_content.dart';
import 'package:physics_quest/data/gravity_content.dart';
import 'package:physics_quest/data/machines_content.dart';
import 'package:physics_quest/data/motion_content.dart';

Future<void> main() async {
  final root = File.fromUri(Platform.script).parent.parent.parent;
  for (final lesson in [
    motionLesson,
    forcesLesson,
    gravityLesson,
    machinesLesson,
  ]) {
    final file = File('${root.path}/backend/seed/lessons/${lesson.id}.json');
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    if (data['id'] != lesson.id) {
      throw StateError('Lesson ID mismatch: ${file.path}');
    }
    data['questions'] = [
      for (final question in lesson.questions) question.toJson(),
    ];
    await file.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(data)}\n',
    );
    stdout.writeln(
      'Synchronized ${lesson.id}: ${lesson.questions.length} exercises',
    );
  }
}
