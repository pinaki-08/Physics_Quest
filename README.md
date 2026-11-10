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

## Learn

The Learn page shows its introduction and the four lesson choices directly.
It does not display a Day streak, Points, or Lessons summary card.

## Motion Tag

Motion Tag replaces the car experiment in Play. It is a single-screen
robot game, not a prediction form or an English sentence-selection quiz.
The learner controls an orange robot's speed and direction while a blue
robot moves along the same straight training track.

Three short English goals have Spanish translations and optional EN/ES
narration:

1. **Catch the blue robot:** move faster to close the gap and enter its
   half-meter tag zone.
2. **Stay beside the blue robot:** first get alongside, then match its
   speed and remain within 0.6 meters for three seconds of active play.
3. **Follow blue and keep a steady gap:** get between 2 and 3.2 meters
   behind, then match speed to maintain that gap for three active seconds.

The blue robot moves at 1 m/s. The player's speed ranges from 0 to 2 m/s;
left/right controls choose direction without representing speed as negative.
Both positions advance in one shared world. Faster/slower/equal relative
speeds produce a shrinking/growing/constant gap, with short bilingual
feedback describing the result. A glowing patch shows the required position;
three stars show steady-gap progress, not a countdown deadline.

Speed sliders and buttons work while moving. **Stop** stops only the player's
robot; **Pause** freezes both robots. Reset restores positions while keeping
chosen controls. There are no lives, fines, response deadlines, or limits on
retries. A blue directional indicator remains available if the other robot
moves offscreen, and the player can still catch up.

Paused play can advance one second at a time. Reduced-motion mode uses this
same step play rather than requiring continuous animation. Language help and
narration pause the game without discarding progress. Backgrounding pauses
play, and speech/animation are cleaned up when leaving.

Catch detection checks the swept movement interval, so a dropped frame
cannot skip a tag. Staying briefly beside blue at a different speed does
not complete a steady-gap goal. The lesson focuses on position, direction,
and relative speed, not projectile motion or a quantitative assessment.

Other games, lesson content, Firebase, and Practice are unchanged. The game
adds no dependencies, database writes, or microphone permissions.

## Hold the Line: guided forces and bilingual help

Hold the Line starts with three gentle guided goals, while retaining an
optional **Survival challenge** in its mode menu. It uses a clearly labelled
box, a blue wind arrow, an orange player-push arrow, and a green target zone.
The old unexplained pod/thrust wording and shaking space scene are removed.

Practice introduces equal opposing pushes, wind from the other side, and
slowing an already-moving box before balancing again. Matching arrow lengths
represents matching actual force magnitudes, not a guessed direction alone.
Three stars fill after three active seconds with balanced forces, a nearly
stationary box, and its position inside the green zone.

**Push left/right** are tap-to-toggle controls: the selected push stays on
until tapped again or **Release** is pressed. A strength slider changes its
magnitude. **Release** removes only the player's force; it does not stop the
box. **Pause** freezes game time. Controls may be configured while paused,
and reset retains the selected push settings.

Physics uses the sum of wind and player forces, acceleration from force and
mass, and exact constant-force position integration. There is no hidden
frame-dependent damping. Balanced forces preserve a moving box's velocity,
and feedback explicitly distinguishes balanced-but-moving from still.
The third guided goal demonstrates a stronger opposite push slowing drift,
followed by equal pushes maintaining the steady position.
Practice pauses at the actual moment an opposing force brings the box to
rest, giving the learner time to match the arrows before continuing. This
is a pause in game time, not an automatic balancing force or hidden damping.

The optional challenge keeps changing, progressively stronger/more frequent
gusts, survival time, and a local best score. Gust magnitudes use readable
5-newton increments and remain within the player's 60-newton control range.
Mode switching pauses and preserves each mode's current box and progress.
An edge ends an attempt honestly, with unlimited retries.

English and Spanish goals, coaching, full control instructions, and
pronunciation are available through EN/ES audio and **How to play**.
Listening or opening help pauses play without discarding force settings.
Reduced-motion and paused play can advance one second at a time.
Backgrounding pauses; leaving stops narration and animation.

Motion Tag and the other activities keep their existing gameplay. There are
no new dependencies, database writes, microphone permissions, or live
translation requests.

## Practice exercise banks

Each Practice activity opens a topic picker for Motion & Speed, Forces,
Gravity & Weight, and Simple Machines:

The Practice menu shows only the four activity cards, without a Daily
Challenge card. The cards use muted blue, sage, clay, and sand surfaces with
large, centered titles. The grid stays two columns on typical phones and
desktop screens, and switches to one column on narrow screens or with
larger accessibility text settings.

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
For Multiple Choice and Fill the Blank, select an answer with its radio button or row, then use the single
**Check answer** / **Comprobar respuesta** button to submit it. Audio,
vocabulary help, and language switching do not submit or clear a selection.

The quiz view uses a cream background, compact white answer rows, and a
centered reading column capped at 720 logical pixels on wider screens.

All activities are untimed and advance only when the student chooses **Next question**.
Correctness, attempts, lives, and streak rewards still apply, but there is no
speed bonus. Explanations are available after every completed exercise.
Blank questions preview a selected word in the sentence without grading it.

Odd One Out is a **drag-to-tray puzzle**. Students drag one of four word cards
into the **Doesn't belong** tray. A correct drop stays in the tray while the
other three cards are grouped together. An incorrect card returns to its
original position and uses one attempt; a cancelled or outside drop does not.
Students can also select a card and press **Move selected card** as a
keyboard/tap alternative. Audio and vocabulary help do not select or submit
cards. After answering, English and Spanish narration model the sentence
"The card [word] does not belong in this group" and explain the category difference.
If attempts run out, the answer is explicitly revealed rather than reported
as a successful discovery.

Each lesson's Match Up activity has **10 rounds of 4 pairs**, not 10 pairs
on a single board. The topic cards show both counts, the quiz labels the
current round, and **Next round** opens the next board after all four pairs
are completed. Drag a left-hand word onto its matching meaning on the right.
On phones, touch and hold a word before dragging so normal vertical scrolling
remains available. Drop targets highlight as a word moves over them, correct
pairs lock, and incorrect or cancelled drops can be retried.
Letter-then-number selection remains available as a keyboard/tap alternative.
The board scrolls when a dragged word reaches the viewport edge, and each
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
