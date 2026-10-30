# physics_quest

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Practice exercise banks

Each Practice activity opens a topic picker for Motion & Speed, Forces,
Gravity & Weight, and Simple Machines:

| Activity | Per lesson | Across all four lessons |
| --- | ---: | ---: |
| Multiple Choice | 10 MCQs | 40 MCQs |
| Fill the Blank | 10 questions | 40 questions |
| Odd One Out | 10 questions | 40 questions |
| Match Up | 10 sets of four pairs | 40 sets |

The 160 exercises are original practice for grades 6-8. They are
not copied from textbooks, official California test items, or a complete
assessment of the NGSS investigation and design performance expectations.
Choice activities have four options and one correct answer. Matching sets
have four unambiguous pairs. Every exercise has a bilingual explanation.
Science contexts include vocabulary, grammar, comparisons, units,
straightforward calculations, and everyday examples.

### Bilingual, self-paced practice

All activities include English and Spanish prompts, choices or pairs, and
explanations. English appears first; **Español** changes the displayed
content without changing choice order, selected answers, or solved pairs.
Compact **EN** and **ES** controls read the question and explanation. Each
answer has a speaker menu with English and Spanish playback instead of
repeated audio buttons. Physics words use the same glossary-driven
highlighting and bilingual pronunciation cards as the Learn lessons.
For choice activities, select an answer with its radio button or row, then use the single
**Check answer** / **Comprobar respuesta** button to submit it. Audio,
vocabulary help, and language switching do not submit or clear a selection.

The quiz view uses a cream background, compact white answer rows, and a
centered reading column capped at 720 logical pixels on wider screens.

All activities are untimed and advance only when the student chooses **Next question**.
Correctness, attempts, lives, and streak rewards still apply, but there is no
speed bonus. Explanations are available after every completed exercise.
Blank questions preview a selected word in the sentence without grading it.
Matching uses letters and numbers: choose a left item, then its corresponding
right item. Correct pairs lock, incorrect pairs can be retried, and each
side has its own English/Spanish audio menu.
Audio stops when advancing, restarting, or leaving a quiz.

`promptEs`, `optionsEs`, and `explanationEs` hold the supplied translations;
there is no runtime translation API. English and Spanish choices must remain
paired at the same indices in source data and must be shuffled together.
Matching pairs store `leftEs` and `rightEs` and use stable canonical indices,
not translated text, to track matches. Missing whole-question translations
are reported explicitly; Spanish audio never substitutes English text.

Bundled content lives in [frontend/lib/data](./frontend/lib/data), and its
Firestore equivalents live in [backend/seed/lessons](./backend/seed/lessons).
Additional exercises use paired English/Spanish records in
[practice_exercises.dart](./frontend/lib/data/practice_exercises.dart).
Lesson values are initialized once as top-level `final` objects so these
typed records can build the question banks; the content remains bundled for
offline use.

After editing bundled questions, regenerate only the seed question fields:

```bash
cd frontend
dart run tool/sync_practice_seeds.dart
```

Both banks must stay synchronized. The app reads saved Firestore
questions when Firebase is available; changing a seed file does not by itself
update the live database. For an existing deployment, publish only the intended
question updates through the Firebase console or an authorized administrative
account, preserving all other lesson fields and student progress. Do not loosen database
security rules to publish content. The existing seed command replaces entire
lesson documents and should only be used when that replacement is intended.

### Curriculum and science references

Sources checked on 2026-10-21:

- [California MS-PS2-1](https://www2.cde.ca.gov/cacs/id/web/29102):
  equal and opposite forces acting on interacting objects.
- [California MS-PS2-2](https://www2.cde.ca.gov/cacs/id/web/29103):
  balanced and unbalanced forces, mass, reference frames, units, and fair
  investigations. Motion calculations and graph questions support these concepts.
- [California MS-PS2-4](https://www2.cde.ca.gov/cacs/id/web/29105):
  gravity as an attractive interaction that depends on the interacting masses.
- [OpenStax, Time, Velocity, and Speed](https://openstax.org/books/college-physics-2e/pages/2-3-time-velocity-and-speed):
  average speed, elapsed time, and interpreting motion.
- [OpenStax, Normal, Tension, and Other Examples of Forces](https://openstax.org/books/college-physics-2e/pages/4-5-normal-tension-and-other-examples-of-forces):
  forces, weight, and support forces.
- [OpenStax, Simple Machines](https://openstax.org/books/college-physics-2e/pages/9-5-simple-machines):
  levers, fulcrums, ramps, pulleys, force-distance trade-offs, and energy
  conservation. These are supplemental applications, not a separate California
  middle-school NGSS performance expectation.

Only introductory concepts from the OpenStax references are used; questions do
not require calculus, trigonometry, or the universal gravitation equation.
Ideal-machine questions explicitly state their friction-free assumptions.

To check question counts, answer keys, and bundled/seed consistency:

```bash
cd frontend
flutter test test/services/question_bank_test.dart
```
