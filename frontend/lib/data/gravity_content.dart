import '../models/lesson.dart';
import 'practice_exercises.dart';

/// The Gravity and Weight lesson. Mirrors backend/seed/lessons/gravity.json.
final gravityLesson = Lesson(
  id: 'gravity',
  title: 'Gravity & Weight',
  subtitle: 'The pull that never lets go.',
  grade: 6,
  estimatedMinutes: 8,
  sections: [
    LessonSection(
      index: 1,
      title: 'What is gravity?',
      titleEs: '¿Qué es la gravedad?',
      art: 'earthPull',
      demo: 'none',
      body:
          'Gravity is a force that pulls every object towards every '
          'other object.\n\n'
          'You only notice it near something huge. The Earth is huge, '
          'so it pulls you, your bag and a falling apple straight down '
          'towards its centre. Gravity never switches off and never '
          'needs to touch you to work.',
      bodyEs:
          'La gravedad es una fuerza que atrae cada objeto hacia '
          'todos los demás objetos. Solo la notas cerca de algo enorme. '
          'La Tierra es enorme, así que te atrae a ti, a tu mochila y a '
          'una manzana que cae, directamente hacia su centro. La '
          'gravedad nunca se apaga y no necesita tocarte para actuar.',
    ),
    LessonSection(
      index: 2,
      title: 'Mass is not weight',
      titleEs: 'La masa no es el peso',
      art: 'massVsWeight',
      demo: 'massWeight',
      body:
          'Mass is how much stuff an object is made of. It is '
          'measured in kilograms and it never changes.\n\n'
          'Weight is the pull of gravity on that mass. It is a force, '
          'so it is measured in newtons. Change the gravity and the '
          'weight changes, even though the mass has not.',
      bodyEs:
          'La masa es la cantidad de materia de la que está hecho '
          'un objeto. Se mide en kilogramos y nunca cambia. El peso es '
          'el tirón de la gravedad sobre esa masa. Es una fuerza, así '
          'que se mide en newtons. Si cambia la gravedad, cambia el '
          'peso, aunque la masa siga siendo la misma.',
    ),
    LessonSection(
      index: 3,
      title: 'Weight changes with the planet',
      titleEs: 'El peso cambia según el planeta',
      art: 'planetRow',
      demo: 'planetWeight',
      body:
          'Every world pulls with its own strength. On Earth gravity '
          'pulls with about 10 newtons for every kilogram.\n\n'
          'The Moon is much smaller, so it pulls about six times more '
          'weakly. Jupiter is enormous and pulls far harder. Same '
          'astronaut, same mass, very different weight.',
      bodyEs:
          'Cada mundo tira con su propia fuerza. En la Tierra la '
          'gravedad tira con unos diez newtons por cada kilogramo. La '
          'Luna es mucho más pequeña, así que tira unas seis veces más '
          'débil. Júpiter es enorme y tira mucho más fuerte. El mismo '
          'astronauta, la misma masa, un peso muy distinto.',
    ),
    LessonSection(
      index: 4,
      title: 'Everything falls together',
      titleEs: 'Todo cae al mismo tiempo',
      art: 'dropTest',
      demo: 'dropRace',
      body:
          'Drop a hammer and a feather and the hammer wins — but not '
          'because it is heavier.\n\n'
          'The feather loses because air pushes back on it. Take the '
          'air away and both hit the ground at exactly the same '
          'moment. Astronauts have actually tried this on the Moon.',
      bodyEs:
          'Si sueltas un martillo y una pluma, gana el martillo, '
          'pero no porque pese más. La pluma pierde porque el aire la '
          'empuja hacia atrás. Si quitas el aire, los dos llegan al '
          'suelo exactamente al mismo tiempo. Los astronautas lo han '
          'probado de verdad en la Luna.',
    ),
  ],
  keyPoints: [
    'Gravity pulls everything towards the centre of the Earth.',
    'Mass is measured in kilograms and never changes.',
    'Weight is a force, measured in newtons.',
    'Weight = mass multiplied by the strength of gravity.',
    'Without air, heavy and light objects fall together.',
  ],
  keyPointsEs: [
    'La gravedad atrae todo hacia el centro de la Tierra.',
    'La masa se mide en kilogramos y nunca cambia.',
    'El peso es una fuerza que se mide en newtons.',
    'Peso = masa multiplicada por la intensidad de la gravedad.',
    'Sin aire, los objetos pesados y ligeros caen al mismo tiempo.',
  ],
  glossary: [
    GlossaryTerm(
      en: 'Gravity',
      es: 'Gravedad',
      definitionEn: 'The force pulling objects towards each other.',
      definitionEs: 'La fuerza que atrae los objetos unos hacia otros.',
      audioEn: 'audio/en/gravity.mp3',
      audioEs: 'audio/es/gravedad.mp3',
    ),
    GlossaryTerm(
      en: 'Mass',
      es: 'Masa',
      definitionEn: 'How much matter an object contains, in kilograms.',
      definitionEs:
          'La cantidad de materia que contiene un objeto, en kilogramos.',
      audioEn: 'audio/en/mass.mp3',
      audioEs: 'audio/es/masa.mp3',
    ),
    GlossaryTerm(
      en: 'Weight',
      es: 'Peso',
      definitionEn: 'The force of gravity on a mass, in newtons.',
      definitionEs: 'La fuerza de la gravedad sobre una masa, en newtons.',
      audioEn: 'audio/en/weight.mp3',
      audioEs: 'audio/es/peso.mp3',
    ),
    GlossaryTerm(
      en: 'Free fall',
      es: 'Caída libre',
      definitionEn: 'Falling with gravity as the only force acting.',
      definitionEs: 'Caer cuando la gravedad es la única fuerza que actúa.',
      audioEn: 'audio/en/free_fall.mp3',
      audioEs: 'audio/es/caida_libre.mp3',
    ),
  ],
  questions: [
    Question(
      id: 'q1',
      promptEs: '¿Cuál de estas propiedades no cambia por viajar a la Luna?',
      optionsEs: ['Tu masa', 'Tu peso', 'La gravedad', 'Tu tamaño en newtons'],
      explanationEs:
          'Viajar a la Luna no cambia la cantidad de materia que '
          'contienes. Tu peso disminuye porque allí la gravedad es menor.',
      explanation:
          'Moving to the Moon does not change the amount of matter in you. '
          'Your weight decreases because gravity is weaker there.',
      prompt: 'Which of these never changes when you travel to the Moon?',
      options: [
        'Your mass',
        'Your weight',
        'The gravity',
        'Your size in newtons',
      ],
      answer: 0,
    ),
    Question(
      id: 'q2',
      promptEs: 'El peso se mide en...',
      optionsEs: ['Newtons', 'Kilogramos', 'Metros', 'Segundos'],
      explanationEs:
          'El peso es una fuerza y las fuerzas se miden en newtons. '
          'Los kilogramos miden la masa.',
      explanation:
          'Weight is a force, and forces are measured in newtons. Kilograms measure mass instead.',
      prompt: 'Weight is measured in...',
      options: ['Newtons', 'Kilograms', 'Metres', 'Seconds'],
      answer: 0,
    ),
    Question(
      id: 'q3',
      promptEs:
          'En la Luna se dejan caer juntos un martillo y una pluma. Ambos...',
      optionsEs: [
        'Llegan al suelo al mismo tiempo',
        'El martillo llega primero',
        'La pluma llega primero',
        'Ninguno cae',
      ],
      explanationEs:
          'En la Luna no hay aire que frene la pluma. '
          'Si solo actúa la gravedad, ambos caen juntos.',
      explanation:
          'The Moon has no air, so nothing slows the feather down. With only gravity acting, everything falls together.',
      prompt:
          'On the Moon a hammer and a feather are dropped together. They...',
      options: [
        'Land at the same time',
        'The hammer lands first',
        'The feather lands first',
        'Neither one falls',
      ],
      answer: 0,
    ),
    Question(
      id: 'q4',
      promptEs: 'Tu masa permanece igual, pero tu ___ cambia en otro planeta.',
      optionsEs: ['peso', 'altura', 'edad', 'volumen'],
      explanationEs:
          'La masa no cambia solo por cambiar de lugar; el peso depende de la gravedad local.',
      explanation:
          'Your mass is the same everywhere, but weight depends on the strength of gravity where you are standing.',
      kind: QuestionKind.blank,
      prompt:
          'Your mass stays the same, but your ___ changes on another planet.',
      options: ['weight', 'height', 'age', 'volume'],
      answer: 0,
    ),
    Question(
      id: 'q5',
      promptEs: 'Tres de estas se miden en newtons. ¿Cuál no?',
      optionsEs: ['Masa', 'Peso', 'Resistencia del aire', 'Fricción'],
      explanationEs:
          'Peso, resistencia del aire y fricción son fuerzas. La masa se mide en kilogramos.',
      explanation:
          'Weight, air resistance and friction are all forces, so all are measured in newtons. Mass is measured in kilograms.',
      kind: QuestionKind.oddOneOut,
      prompt: 'Three of these are measured in newtons. Which one is not?',
      options: ['Mass', 'Weight', 'Air resistance', 'Friction'],
      answer: 0,
    ),
    Question(
      id: 'q6',
      promptEs: 'Relaciona cada magnitud con su unidad o significado.',
      explanationEs:
          'Masa y peso tienen unidades distintas; en caída libre solo actúa la gravedad.',
      explanation:
          'Mass and weight sound alike but use different units, and free fall means gravity is the only force acting.',
      kind: QuestionKind.match,
      prompt: 'Match each quantity to its unit or meaning.',
      points: 20,
      pairs: [
        MatchPair(
          left: 'Mass',
          right: 'Kilograms',
          leftEs: 'Masa',
          rightEs: 'Kilogramos',
        ),
        MatchPair(
          left: 'Weight',
          right: 'Newtons',
          leftEs: 'Peso',
          rightEs: 'Newtons',
        ),
        MatchPair(
          left: 'Gravity on Earth',
          right: 'About 10 N per kg',
          leftEs: 'Gravedad en la Tierra',
          rightEs: 'Aproximadamente 10 N/kg',
        ),
        MatchPair(
          left: 'Free fall',
          right: 'Only gravity acting',
          leftEs: 'Caída libre',
          rightEs: 'Solo actúa la gravedad',
        ),
      ],
    ),
    Question(
      id: 'q7',
      promptEs:
          '¿Qué afirmación describe la gravedad entre dos objetos con masa?',
      optionsEs: [
        'Solo un objeto atrae al otro',
        'Los objetos siempre se empujan para separarse',
        'Solo los planetas pueden ejercer gravedad',
        'Los objetos se atraen entre sí',
      ],
      explanationEs:
          'La gravedad es una interacción de atracción entre masas. '
          'Ambos objetos se atraen, aunque la fuerza puede ser muy pequeña.',
      prompt:
          'Which statement describes gravity between any two objects with mass?',
      options: [
        'Only one object pulls on the other',
        'The objects always push each other apart',
        'Only planets can exert gravity',
        'The objects attract each other',
      ],
      answer: 3,
      explanation:
          'Gravity is an attractive interaction between masses. Both '
          'objects pull on each other, although the force may be very small.',
    ),
    Question(
      id: 'q8',
      promptEs:
          'Dos objetos permanecen a la misma distancia. Si aumenta la '
          'masa de uno, ¿qué pasa con su atracción gravitatoria?',
      optionsEs: [
        'Se hace más fuerte',
        'Desaparece',
        'Se hace más débil',
        'Siempre permanece igual',
      ],
      explanationEs:
          'A la misma distancia, aumentar cualquiera de las masas '
          'aumenta la atracción gravitatoria entre los objetos.',
      prompt:
          'Two objects stay the same distance apart. If one object\'s mass '
          'increases, what happens to their gravitational attraction?',
      options: [
        'It becomes stronger',
        'It disappears',
        'It becomes weaker',
        'It always stays the same',
      ],
      answer: 0,
      explanation:
          'At the same separation, increasing either mass increases the '
          'gravitational attraction between the objects.',
    ),
    Question(
      id: 'q9',
      promptEs: '¿Qué medición describe la masa en lugar del peso?',
      optionsEs: ['40 newtons', '4 kilogramos', '4 metros', '40 segundos'],
      explanationEs:
          'Los kilogramos miden la masa. Los newtons miden fuerzas, '
          'incluido el peso. Los metros y segundos miden distancia y tiempo.',
      prompt: 'Which measurement describes mass rather than weight?',
      options: ['40 newtons', '4 kilograms', '4 metres', '40 seconds'],
      answer: 1,
      explanation:
          'Kilograms measure mass. Newtons measure force, including weight. '
          'Metres and seconds measure distance and time.',
    ),
    Question(
      id: 'q10',
      promptEs:
          'Una mochila tiene una masa de 3 kg. La gravedad ejerce '
          '10 N por cada kilogramo. ¿Cuál es el peso de la mochila?',
      optionsEs: ['3 N', '10 N', '30 N', '300 N'],
      explanationEs:
          'El peso es la masa multiplicada por la intensidad del campo '
          'gravitatorio: 3 kilogramos por 10 newtons por kilogramo = 30 newtons.',
      prompt:
          'A backpack has a mass of 3 kg. Gravity pulls with 10 N for each '
          'kilogram. What is the backpack\'s weight?',
      options: ['3 N', '10 N', '30 N', '300 N'],
      answer: 2,
      explanation:
          'Weight is mass multiplied by gravitational field strength: '
          '3 kilograms times 10 newtons per kilogram = 30 newtons.',
    ),
    Question(
      id: 'q11',
      promptEs:
          'El mismo objeto pasa de un planeta con gravedad de 10 N/kg '
          'a otro con 5 N/kg. ¿Cómo cambia su peso?',
      optionsEs: [
        'Su peso se duplica',
        'Su masa se reduce a la mitad',
        'Su peso permanece igual',
        'Su peso se reduce a la mitad',
      ],
      explanationEs:
          'La masa permanece igual, pero la intensidad del campo '
          'gravitatorio se reduce a la mitad. Como el peso es masa por '
          'intensidad del campo, el peso también se reduce a la mitad.',
      prompt:
          'The same object moves from a planet with gravity of 10 N/kg '
          'to one with 5 N/kg. How does its weight change?',
      options: [
        'Its weight doubles',
        'Its mass is cut in half',
        'Its weight stays the same',
        'Its weight becomes half as large',
      ],
      answer: 3,
      explanation:
          'The mass stays the same, but the gravitational field strength '
          'is halved. Since weight is mass times field strength, weight is halved.',
    ),
    Question(
      id: 'q12',
      promptEs:
          'Unos astronautas orbitan la Tierra por encima de la atmósfera. '
          '¿Qué afirmación sobre la gravedad terrestre es correcta?',
      optionsEs: [
        'Todavía atrae a los astronautas',
        'Termina en el límite de la atmósfera',
        'Los trajes espaciales la bloquean por completo',
        'Solo actúa sobre objetos en reposo',
      ],
      explanationEs:
          'La gravedad actúa sin contacto y se extiende más allá '
          'de la atmósfera. La Tierra sigue atrayendo a los astronautas '
          'y a su nave en órbita.',
      prompt:
          'Astronauts orbit Earth above the atmosphere. Which statement '
          'about Earth\'s gravity is correct?',
      options: [
        'It still pulls on the astronauts',
        'It stops at the top of the atmosphere',
        'Spacesuits block it completely',
        'It acts only on objects that are at rest',
      ],
      answer: 0,
      explanation:
          'Gravity acts without contact and extends beyond the atmosphere. '
          'Earth still pulls on astronauts and their spacecraft in orbit.',
    ),
    Question(
      id: 'q13',
      promptEs:
          'Una pelota se lanza verticalmente hacia arriba. Después '
          'de salir de la mano, ¿hacia dónde la atrae la gravedad '
          'mientras sube?',
      optionsEs: [
        'Hacia arriba',
        'Hacia un lado',
        'Hacia abajo',
        'Hacia ningún lado hasta que empiece a caer',
      ],
      explanationEs:
          'Cerca de la Tierra, la gravedad atrae hacia su centro '
          'incluso cuando el objeto sube. Esta fuerza hacia abajo '
          'frena la pelota mientras asciende.',
      prompt:
          'A ball is thrown straight upward. After it leaves the hand, '
          'which way does Earth\'s gravity pull while the ball is rising?',
      options: [
        'Upward',
        'Sideways',
        'Downward',
        'Nowhere until the ball starts falling',
      ],
      answer: 2,
      explanation:
          'Near Earth, gravity pulls toward Earth\'s centre even while an '
          'object moves upward. This downward force slows the rising ball.',
    ),
    ...gravityPracticeQuestions,
  ],
);
