/// Plain data model for a lesson. Mirrors the Firestore document shape in
/// backend/seed/lessons/, so the same JSON works locally and from the server.
class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final int grade;
  final int estimatedMinutes;
  final List<LessonSection> sections;
  final List<String> keyPoints;
  final List<String> keyPointsEs;
  final List<GlossaryTerm> glossary;
  final List<Question> questions;

  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.grade,
    required this.estimatedMinutes,
    required this.sections,
    required this.keyPoints,
    required this.keyPointsEs,
    required this.glossary,
    required this.questions,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as String,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String? ?? '',
    grade: json['grade'] as int? ?? 6,
    estimatedMinutes: json['estimatedMinutes'] as int? ?? 0,
    sections: (json['sections'] as List<dynamic>? ?? [])
        .map((e) => LessonSection.fromJson(e as Map<String, dynamic>))
        .toList(),
    keyPoints: (json['keyPoints'] as List<dynamic>? ?? []).cast<String>(),
    keyPointsEs: (json['keyPointsEs'] as List<dynamic>? ?? []).cast<String>(),
    glossary: (json['glossary'] as List<dynamic>? ?? [])
        .map((e) => GlossaryTerm.fromJson(e as Map<String, dynamic>))
        .toList(),
    questions: (json['questions'] as List<dynamic>? ?? [])
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Lesson withTranslationFallback(Lesson fallback) {
    final fallbackSections = {
      for (final section in fallback.sections) section.index: section,
    };

    return Lesson(
      id: id,
      title: title,
      subtitle: subtitle,
      grade: grade,
      estimatedMinutes: estimatedMinutes,
      sections: [
        for (final section in sections)
          section.withTranslationFallback(fallbackSections[section.index]),
      ],
      keyPoints: keyPoints,
      keyPointsEs: keyPointsEs.isEmpty ? fallback.keyPointsEs : keyPointsEs,
      glossary: glossary,
      questions: questions,
    );
  }

  int get totalPoints =>
      questions.fold(0, (sum, question) => sum + question.points);
}

class LessonSection {
  final int index;
  final String title;
  final String titleEs;
  final String body;

  final String bodyEs;

  /// Names a painted illustration and an interactive demo widget. Kept as
  /// strings so the content can live in Firestore while the code stays in Dart.
  final String art;
  final String demo;

  const LessonSection({
    required this.index,
    required this.title,
    required this.titleEs,
    required this.body,
    required this.bodyEs,
    required this.art,
    required this.demo,
  });

  factory LessonSection.fromJson(Map<String, dynamic> json) => LessonSection(
    index: json['index'] as int,
    title: json['title'] as String,
    titleEs: json['titleEs'] as String? ?? '',
    body: json['body'] as String,
    bodyEs: json['bodyEs'] as String? ?? '',
    art: json['art'] as String,
    demo: json['demo'] as String,
  );

  LessonSection withTranslationFallback(LessonSection? fallback) {
    if (fallback == null) return this;
    return LessonSection(
      index: index,
      title: title,
      titleEs: titleEs.isEmpty ? fallback.titleEs : titleEs,
      body: body,
      bodyEs: bodyEs.isEmpty ? fallback.bodyEs : bodyEs,
      art: art,
      demo: demo,
    );
  }
}

/// How a practice item is played. Stored as a string in Firestore so new
/// kinds can be added to content without a schema migration.
enum QuestionKind { mcq, blank, oddOneOut, match }

class MatchPair {
  final String left;
  final String right;

  const MatchPair({required this.left, required this.right});

  factory MatchPair.fromJson(Map<String, dynamic> json) =>
      MatchPair(left: json['left'] as String, right: json['right'] as String);
}

class Question {
  final String id;
  final String prompt;
  final List<String> options;
  final int answer;
  final int points;
  final QuestionKind kind;
  final List<MatchPair> pairs;

  /// Shown once the question is settled, so a student who runs out of tries
  /// learns why rather than just what.
  final String explanation;

  const Question({
    required this.id,
    required this.prompt,
    this.options = const [],
    this.answer = 0,
    this.points = 10,
    this.kind = QuestionKind.mcq,
    this.pairs = const [],
    this.explanation = '',
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json['id'] as String,
    prompt: json['prompt'] as String,
    options: (json['options'] as List<dynamic>? ?? []).cast<String>(),
    answer: json['answer'] as int? ?? 0,
    points: json['points'] as int? ?? 10,
    kind: QuestionKind.values.firstWhere(
      (k) => k.name == (json['kind'] as String? ?? 'mcq'),
      orElse: () => QuestionKind.mcq,
    ),
    pairs: (json['pairs'] as List<dynamic>? ?? [])
        .map((e) => MatchPair.fromJson(e as Map<String, dynamic>))
        .toList(),
    explanation: json['explanation'] as String? ?? '',
  );

  bool isCorrect(int choice) => choice == answer;
}

/// A scientific term with both languages and its pronunciation clips, which is
/// what the bilingual audio support is built on.
class GlossaryTerm {
  final String en;
  final String es;
  final String definitionEn;
  final String definitionEs;
  final String audioEn;
  final String audioEs;

  const GlossaryTerm({
    required this.en,
    required this.es,
    required this.definitionEn,
    required this.definitionEs,
    required this.audioEn,
    required this.audioEs,
  });

  factory GlossaryTerm.fromJson(Map<String, dynamic> json) => GlossaryTerm(
    en: json['en'] as String,
    es: json['es'] as String,
    definitionEn: json['definitionEn'] as String? ?? '',
    definitionEs: json['definitionEs'] as String? ?? '',
    audioEn: json['audioEn'] as String? ?? '',
    audioEs: json['audioEs'] as String? ?? '',
  );
}
