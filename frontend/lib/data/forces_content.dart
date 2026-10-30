import '../models/lesson.dart';
import 'practice_exercises.dart';

/// The Forces lesson as structured data. This is the same content as
/// backend/seed/lessons/forces.json — once Firestore is connected the
/// FirestoreLessonRepository replaces this as the source.
final forcesLesson = Lesson(
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
      promptEs: 'La mejor descripción de una fuerza es...',
      optionsEs: [
        'Un empujón o un tirón',
        'Una forma de energía',
        'Un tipo de velocidad',
        'Una partícula diminuta',
      ],
      explanationEs:
          'Una fuerza es un empujón o un tirón. La energía y la '
          'velocidad son magnitudes distintas; una fuerza no es una partícula.',
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
      promptEs:
          'Una cuerda está en reposo. Dos equipos tiran de ella en '
          'sentidos opuestos con 50 N cada uno. ¿Qué ocurre?',
      optionsEs: [
        'La cuerda permanece en reposo',
        'Se mueve a la izquierda',
        'Se mueve a la derecha',
        'La cuerda se rompe',
      ],
      explanationEs:
          'Las fuerzas iguales y opuestas están equilibradas. '
          'La fuerza neta es cero, así que no cambia el movimiento.',
      explanation:
          'Equal forces in opposite directions are balanced, so they cancel out and the motion does not change.',
      prompt:
          'A rope is at rest. Two teams pull it in opposite directions '
          'with 50 N each. What happens?',
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
      promptEs: '¿Qué fuerza frena un libro que se desliza sobre una mesa?',
      optionsEs: ['Fricción', 'Gravedad', 'Magnetismo', 'Resistencia del aire'],
      explanationEs:
          'La fricción entre el libro y la mesa se opone al deslizamiento. '
          'La resistencia del aire suele ser más importante a velocidades altas.',
      explanation:
          'Friction acts between two touching surfaces and opposes sliding. Air resistance matters far more at high speed.',
      prompt: 'Which force slows a book sliding across a table?',
      options: ['Friction', 'Gravity', 'Magnetism', 'Air resistance'],
      answer: 0,
    ),
    Question(
      id: 'q4',
      promptEs: 'Las fuerzas se miden en ___.',
      optionsEs: ['newtons', 'kilogramos', 'metros', 'litros'],
      explanationEs: 'La fuerza se mide en newtons; los kilogramos miden masa.',
      explanation:
          'Force is measured in newtons. Kilograms measure mass, which is a different quantity.',
      kind: QuestionKind.blank,
      prompt: 'Forces are measured in ___.',
      options: ['newtons', 'kilograms', 'metres', 'litres'],
      answer: 0,
    ),
    Question(
      id: 'q5',
      promptEs: 'Tres de estas son fuerzas. ¿Cuál no lo es?',
      optionsEs: [
        'Temperatura',
        'Fricción',
        'Gravedad',
        'Resistencia del aire',
      ],
      explanationEs:
          'La temperatura describe qué tan caliente está algo. No es un empujón ni un tirón.',
      explanation:
          'Temperature tells you how hot something is. It has no direction and cannot push or pull anything.',
      kind: QuestionKind.oddOneOut,
      prompt: 'Three of these are forces. Which one is not?',
      options: ['Temperature', 'Friction', 'Gravity', 'Air resistance'],
      answer: 0,
    ),
    Question(
      id: 'q6',
      promptEs: 'Relaciona cada fuerza con lo que hace.',
      explanationEs:
          'Cada fuerza actúa de una manera: atraer, oponerse al deslizamiento, resistir el movimiento en el aire o aplicar un empujón.',
      explanation:
          'Each force acts in its own way: some pull down, some resist movement, and some come from you.',
      kind: QuestionKind.match,
      prompt: 'Match each force to what it does.',
      points: 20,
      pairs: [
        MatchPair(
          left: 'Gravity',
          right: 'Pulls things downwards',
          leftEs: 'Gravedad',
          rightEs: 'Atrae los objetos hacia abajo',
        ),
        MatchPair(
          left: 'Friction',
          right: 'Slows sliding surfaces',
          leftEs: 'Fricción',
          rightEs: 'Frena el deslizamiento entre superficies',
        ),
        MatchPair(
          left: 'Air resistance',
          right: 'Pushes back on movers',
          leftEs: 'Resistencia del aire',
          rightEs: 'Se opone al movimiento a través del aire',
        ),
        MatchPair(
          left: 'Applied force',
          right: 'The push you give',
          leftEs: 'Fuerza aplicada',
          rightEs: 'El empujón que aplicas',
        ),
      ],
    ),
    Question(
      id: 'q7',
      promptEs:
          'Sobre un carrito actúan 12 N hacia la derecha y 7 N hacia '
          'la izquierda. ¿Cuál es la fuerza neta horizontal?',
      optionsEs: [
        '19 N hacia la derecha',
        '5 N hacia la izquierda',
        '5 N hacia la derecha',
        '0 N',
      ],
      explanationEs:
          'Las fuerzas opuestas se restan: 12 menos 7 = 5 N. '
          'La fuerza neta apunta a la derecha porque esa fuerza es mayor.',
      prompt:
          'A cart is pushed with 12 N to the right and 7 N to the left. '
          'What is the net horizontal force?',
      options: [
        '19 N to the right',
        '5 N to the left',
        '5 N to the right',
        '0 N',
      ],
      answer: 2,
      explanation:
          'Opposite forces subtract: 12 minus 7 = 5 N. The net force points '
          'right because the rightward force is larger.',
    ),
    Question(
      id: 'q8',
      promptEs:
          'Un carrito avanza en línea recta a velocidad constante. '
          '¿Qué ocurre si la fuerza neta sobre él sigue siendo cero?',
      optionsEs: [
        'Debe detenerse de inmediato',
        'Aumenta su velocidad',
        'Cambia al sentido contrario',
        'Sigue moviéndose a la misma velocidad y en la misma dirección',
      ],
      explanationEs:
          'Una fuerza neta igual a cero significa que el movimiento no '
          'cambia. Un carrito que ya se mueve continúa a la misma '
          'velocidad y en la misma dirección.',
      prompt:
          'A cart moves in a straight line at a steady speed. '
          'What happens if the net force on it remains zero?',
      options: [
        'It must stop immediately',
        'It speeds up',
        'It reverses direction',
        'It keeps moving at the same speed and direction',
      ],
      answer: 3,
      explanation:
          'Zero net force means no change in motion. A cart that is already '
          'moving continues at the same speed in the same direction.',
    ),
    Question(
      id: 'q9',
      promptEs:
          'Un carrito vacío y otro cargado parten del reposo. La misma '
          'fuerza neta actúa sobre ambos durante el mismo tiempo. '
          '¿Cuál aumenta más su velocidad?',
      optionsEs: [
        'El carrito vacío',
        'El carrito cargado',
        'Ambos cambian su velocidad en la misma medida',
        'Ningún carrito puede cambiar de velocidad',
      ],
      explanationEs:
          'Con la misma fuerza neta, el carrito de menor masa tiene '
          'mayor aceleración. Durante el mismo tiempo, su velocidad cambia más.',
      prompt:
          'An empty cart and a loaded cart start at rest. The same net force '
          'acts on each for the same time. Which gains more speed?',
      options: [
        'The empty cart',
        'The loaded cart',
        'Both change speed by the same amount',
        'Neither cart can change speed',
      ],
      answer: 0,
      explanation:
          'For the same net force, the cart with less mass has greater '
          'acceleration. Over the same time, its speed changes more.',
    ),
    Question(
      id: 'q10',
      promptEs: '¿Qué acción es un ejemplo de fuerza aplicada?',
      optionsEs: [
        'La Tierra atrae una pelota que cae',
        'Un estudiante empuja una silla',
        'Un imán atrae un clip sin tocarlo',
        'La Luna atrae el agua del océano',
      ],
      explanationEs:
          'Una fuerza aplicada es un empujón o un tirón directo de una '
          'persona u otro objeto. Empujar una silla es una interacción por contacto.',
      prompt: 'Which action is an example of an applied force?',
      options: [
        'Earth attracts a falling ball',
        'A student pushes a chair',
        'A magnet attracts a paper clip without touching it',
        'The Moon attracts ocean water',
      ],
      answer: 1,
      explanation:
          'An applied force is a direct push or pull by a person or another '
          'object. Pushing a chair is a contact interaction.',
    ),
    Question(
      id: 'q11',
      promptEs:
          '¿Por qué un paracaídas abierto ayuda a que una persona caiga '
          'más despacio?',
      optionsEs: [
        'Elimina la gravedad',
        'Hace que la persona pierda masa',
        'Aumenta la resistencia del aire',
        'Impide que el aire toque a la persona',
      ],
      explanationEs:
          'Un paracaídas abierto presenta una superficie mayor al aire. '
          'Esto aumenta la resistencia del aire y reduce la velocidad '
          'final de caída.',
      prompt: 'Why does an open parachute help a skydiver fall more slowly?',
      options: [
        'It removes gravity',
        'It makes the skydiver lose mass',
        'It increases air resistance',
        'It stops air from touching the skydiver',
      ],
      answer: 2,
      explanation:
          'An open parachute presents a larger area to the air. This '
          'increases air resistance and reduces the eventual falling speed.',
    ),
    Question(
      id: 'q12',
      promptEs:
          'Un estudiante empuja una pared con 30 N. '
          '¿Qué fuerza ejerce la pared sobre el estudiante?',
      optionsEs: [
        '30 N en sentido contrario',
        '30 N en el mismo sentido',
        'Ninguna fuerza',
        '60 N en sentido contrario',
      ],
      explanationEs:
          'Dos objetos que interactúan ejercen fuerzas iguales en '
          'sentidos opuestos. Estas fuerzas actúan sobre objetos distintos: '
          'la pared y el estudiante.',
      prompt:
          'A student pushes on a wall with 30 N. What force does the wall '
          'exert on the student?',
      options: [
        '30 N in the opposite direction',
        '30 N in the same direction',
        'No force',
        '60 N in the opposite direction',
      ],
      answer: 0,
      explanation:
          'Interacting objects exert equal forces in opposite directions. '
          'These forces act on different objects: the wall and the student.',
    ),
    Question(
      id: 'q13',
      promptEs:
          'Para investigar cómo cambia el movimiento de un carrito al '
          'variar la intensidad del empujón, ¿qué deben mantener igual '
          'los estudiantes?',
      optionsEs: [
        'La intensidad del empujón',
        'La velocidad final del carrito',
        'La distancia que recorre el carrito',
        'El carrito, la superficie de la pista y la duración del empujón',
      ],
      explanationEs:
          'Una prueba justa cambia solo la intensidad del empujón. '
          'Mantener iguales el carrito, la superficie y la duración '
          'permite estudiar únicamente ese efecto.',
      prompt:
          'To test how push strength changes a cart\'s motion, what should '
          'students keep the same?',
      options: [
        'The strength of the push',
        'The final speed of the cart',
        'The distance the cart travels',
        'The cart, track surface, and push duration',
      ],
      answer: 3,
      explanation:
          'A fair test changes only push strength. Keeping the cart, '
          'surface, and push duration the same helps isolate its effect.',
    ),
    ...forcesPracticeQuestions,
  ],
);
