import '../models/lesson.dart';

/// The Forces lesson as structured data. This is the same content as
/// backend/seed/lessons/forces.json — once Firestore is connected the
/// FirestoreLessonRepository replaces this as the source.
const forcesLesson = Lesson(
  id: 'forces',
  title: 'Forces',
  subtitle: 'Pushes, pulls and everything they change.',
  grade: 6,
  estimatedMinutes: 8,
  sections: [
    LessonSection(
      index: 1,
      title: 'What is a force?',
      titleEs: '¿Qué es una fuerza?',
      art: 'pushPull',
      demo: 'pushPull',
      body:
          'A force is simply a push or a pull.\n\n'
          'You can never see a force itself — but you can always see '
          'what it does. Forces make things start moving, stop, speed '
          'up, slow down, change direction or change shape.',
      bodyEs:
          'Una fuerza es simplemente un empujón o un tirón. '
          'Nunca puedes ver la fuerza en sí, pero siempre puedes ver lo que '
          'hace. Las fuerzas hacen que las cosas empiecen a moverse, se '
          'detengan, aceleren, frenen, cambien de dirección o cambien de forma.',
    ),
    LessonSection(
      index: 2,
      title: 'Forces have size and direction',
      titleEs: 'Las fuerzas tienen magnitud y dirección',
      art: 'newtonMeter',
      demo: 'forceSize',
      body:
          'We measure force in newtons (N). One newton is roughly '
          'the weight of a small apple sitting in your hand.\n\n'
          'Size alone is not enough — a force also needs a direction. '
          '10 N to the right is a completely different force from '
          '10 N to the left.',
      bodyEs:
          'Medimos la fuerza en newtons. Un newton es más o menos el peso '
          'de una manzana pequeña en tu mano. El tamaño no basta: una fuerza '
          'también necesita una dirección. Diez newtons hacia la derecha son '
          'una fuerza completamente distinta de diez newtons hacia la izquierda.',
    ),
    LessonSection(
      index: 3,
      title: 'Balanced and unbalanced',
      titleEs: 'Fuerzas equilibradas y desequilibradas',
      art: 'tugOfWar',
      demo: 'tugOfWar',
      body:
          'When two forces are equal in size and point in opposite '
          'directions they cancel out. These are balanced forces, and '
          'the motion does not change.\n\n'
          'If one side is stronger the forces are unbalanced, and the '
          'object moves in the direction of the bigger force.',
      bodyEs:
          'Cuando dos fuerzas son iguales en tamaño y apuntan en '
          'direcciones opuestas, se anulan. Son fuerzas equilibradas y el '
          'movimiento no cambia. Si un lado es más fuerte, las fuerzas están '
          'desequilibradas y el objeto se mueve en la dirección de la fuerza '
          'mayor.',
    ),
    LessonSection(
      index: 4,
      title: 'Forces around you',
      titleEs: 'Fuerzas a tu alrededor',
      art: 'gravity',
      demo: 'forceTypes',
      body:
          'Gravity pulls the apple down. Air resistance holds the '
          'parachute back. Tap each card to meet the rest.',
      bodyEs:
          'La gravedad tira de la manzana hacia abajo. La resistencia del '
          'aire frena el paracaídas. Toca cada tarjeta para conocer las demás.',
    ),
  ],
  keyPoints: [
    'A force is a push or a pull.',
    'Force is measured in newtons (N).',
    'Every force has a size and a direction.',
    'Balanced forces change nothing.',
    'Unbalanced forces change motion.',
  ],
  keyPointsEs: [
    'Una fuerza es un empujón o un tirón.',
    'La fuerza se mide en newtons (N).',
    'Toda fuerza tiene una magnitud y una dirección.',
    'Las fuerzas equilibradas no producen cambios.',
    'Las fuerzas desequilibradas cambian el movimiento.',
  ],
  glossary: [
    GlossaryTerm(
      en: 'Force',
      es: 'Fuerza',
      definitionEn: 'A push or a pull acting on an object.',
      definitionEs: 'Un empujón o un tirón que actúa sobre un objeto.',
      audioEn: 'audio/en/force.mp3',
      audioEs: 'audio/es/fuerza.mp3',
    ),
    GlossaryTerm(
      en: 'Newton',
      es: 'Newton',
      definitionEn: 'The unit used to measure force.',
      definitionEs: 'La unidad que se usa para medir la fuerza.',
      audioEn: 'audio/en/newton.mp3',
      audioEs: 'audio/es/newton.mp3',
    ),
    GlossaryTerm(
      en: 'Gravity',
      es: 'Gravedad',
      definitionEn:
          'The force that pulls everything towards the centre of the Earth.',
      definitionEs: 'La fuerza que atrae todo hacia el centro de la Tierra.',
      audioEn: 'audio/en/gravity.mp3',
      audioEs: 'audio/es/gravedad.mp3',
    ),
    GlossaryTerm(
      en: 'Friction',
      es: 'Fricción',
      definitionEn: 'The force that slows down sliding surfaces.',
      definitionEs: 'La fuerza que frena las superficies que se deslizan.',
      audioEn: 'audio/en/friction.mp3',
      audioEs: 'audio/es/friccion.mp3',
    ),
    GlossaryTerm(
      en: 'Air resistance',
      es: 'Resistencia del aire',
      definitionEn: 'Air pushing back on anything moving through it.',
      definitionEs:
          'El aire que empuja en contra de todo lo que se mueve a través de él.',
      audioEn: 'audio/en/air_resistance.mp3',
      audioEs: 'audio/es/resistencia_del_aire.mp3',
    ),
    GlossaryTerm(
      en: 'Balanced forces',
      es: 'Fuerzas equilibradas',
      definitionEn: 'Equal forces in opposite directions, which cancel out.',
      definitionEs: 'Fuerzas iguales en direcciones opuestas, que se anulan.',
      audioEn: 'audio/en/balanced_forces.mp3',
      audioEs: 'audio/es/fuerzas_equilibradas.mp3',
    ),
  ],
  questions: [
    Question(
      id: 'q1',
      explanation:
          'A force is simply a push or a pull. Energy and speed are different quantities, and a force is not a particle.',
      prompt: 'A force is best described as...',
      options: [
        'A push or a pull',
        'A kind of energy',
        'A type of speed',
        'A tiny particle',
      ],
      answer: 0,
    ),
    Question(
      id: 'q2',
      explanation:
          'Equal forces in opposite directions are balanced, so they cancel out and the motion does not change.',
      prompt: 'Two teams each pull a rope with 50 N. What happens?',
      options: [
        'The rope stays still',
        'It moves left',
        'It moves right',
        'The rope snaps',
      ],
      answer: 0,
    ),
    Question(
      id: 'q3',
      explanation:
          'Friction acts between two touching surfaces and opposes sliding. Air resistance matters far more at high speed.',
      prompt: 'Which force slows a book sliding across a table?',
      options: ['Friction', 'Gravity', 'Magnetism', 'Air resistance'],
      answer: 0,
    ),
    Question(
      id: 'q4',
      explanation:
          'Force is measured in newtons. Kilograms measure mass, which is a different quantity.',
      kind: QuestionKind.blank,
      prompt: 'Forces are measured in ___.',
      options: ['newtons', 'kilograms', 'metres', 'litres'],
      answer: 0,
    ),
    Question(
      id: 'q5',
      explanation:
          'Temperature tells you how hot something is. It has no direction and cannot push or pull anything.',
      kind: QuestionKind.oddOneOut,
      prompt: 'Three of these are forces. Which one is not?',
      options: ['Temperature', 'Friction', 'Gravity', 'Air resistance'],
      answer: 0,
    ),
    Question(
      id: 'q6',
      explanation:
          'Each force acts in its own way: some pull down, some resist movement, and some come from you.',
      kind: QuestionKind.match,
      prompt: 'Match each force to what it does.',
      points: 20,
      pairs: [
        MatchPair(left: 'Gravity', right: 'Pulls things downwards'),
        MatchPair(left: 'Friction', right: 'Slows sliding surfaces'),
        MatchPair(left: 'Air resistance', right: 'Pushes back on movers'),
        MatchPair(left: 'Applied force', right: 'The push you give'),
      ],
    ),
  ],
);
