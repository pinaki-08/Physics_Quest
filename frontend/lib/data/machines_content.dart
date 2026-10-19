import '../models/lesson.dart';

/// The Simple Machines lesson. Mirrors backend/seed/lessons/machines.json.
const machinesLesson = Lesson(
  id: 'machines',
  title: 'Simple Machines',
  subtitle: 'Clever ways to make a hard job easy.',
  grade: 7,
  estimatedMinutes: 9,
  sections: [
    LessonSection(
      index: 1,
      title: 'Trading force for distance',
      titleEs: 'Intercambiar fuerza por distancia',
      art: 'effortTrade',
      demo: 'none',
      body:
          'A simple machine does not give you extra energy. It just '
          'lets you use less force — as long as you move that force '
          'further.\n\n'
          'Lifting a heavy crate straight up needs a huge push over a '
          'short distance. Push it up a long ramp instead and you need '
          'far less force, but you have to push for much longer. The '
          'work done comes out the same.',
      bodyEs:
          'Una máquina simple no te da energía extra. Solo te '
          'permite usar menos fuerza, siempre que muevas esa fuerza más '
          'lejos. Levantar una caja pesada en línea recta necesita un '
          'empujón enorme en una distancia corta. Súbela por una rampa '
          'larga y necesitarás mucha menos fuerza, pero tendrás que '
          'empujar durante mucho más rato. El trabajo realizado es el '
          'mismo.',
    ),
    LessonSection(
      index: 2,
      title: 'Levers',
      titleEs: 'Palancas',
      art: 'lever',
      demo: 'lever',
      body:
          'A lever is a stiff bar that turns on a fixed point called '
          'the fulcrum.\n\n'
          'The further the fulcrum sits from your hands, the more the '
          'bar multiplies your push. Move the fulcrum close to the load '
          'and a small effort lifts a heavy weight. Scissors, '
          'wheelbarrows and even your forearm are all levers.',
      bodyEs:
          'Una palanca es una barra rígida que gira sobre un punto '
          'fijo llamado fulcro. Cuanto más lejos está el fulcro de tus '
          'manos, más multiplica la barra tu empujón. Coloca el fulcro '
          'cerca de la carga y un esfuerzo pequeño levantará un peso '
          'grande. Las tijeras, las carretillas e incluso tu antebrazo '
          'son palancas.',
    ),
    LessonSection(
      index: 3,
      title: 'Ramps',
      titleEs: 'Rampas',
      art: 'ramp',
      demo: 'rampForce',
      body:
          'A ramp, or inclined plane, spreads a lift out over a '
          'longer path.\n\n'
          'The height you gain is fixed, so a longer ramp means a '
          'gentler slope and a smaller push. Double the length of the '
          'ramp and you halve the force — but you travel twice as far.',
      bodyEs:
          'Una rampa, o plano inclinado, reparte una subida a lo '
          'largo de un camino más largo. La altura que ganas es fija, '
          'así que una rampa más larga significa una pendiente más '
          'suave y un empujón más pequeño. Si duplicas la longitud de '
          'la rampa, reduces la fuerza a la mitad, pero recorres el '
          'doble de distancia.',
    ),
    LessonSection(
      index: 4,
      title: 'Pulleys',
      titleEs: 'Poleas',
      art: 'pulley',
      demo: 'pulley',
      body:
          'A pulley is a wheel with a rope over it. One pulley just '
          'changes the direction you pull.\n\n'
          'Add more wheels and the rope shares the load between several '
          'strands. With four strands holding the crate you only pull a '
          'quarter of its weight — but you must pull four times as much '
          'rope.',
      bodyEs:
          'Una polea es una rueda con una cuerda por encima. Una '
          'sola polea solo cambia la dirección en la que tiras. Añade '
          'más ruedas y la cuerda reparte la carga entre varios ramales. '
          'Con cuatro ramales sujetando la caja solo tiras de una cuarta '
          'parte de su peso, pero debes tirar de cuatro veces más cuerda.',
    ),
  ],
  keyPoints: [
    'A simple machine trades force for distance.',
    'It never creates extra energy.',
    'A lever turns on a fulcrum.',
    'A longer ramp needs a smaller push.',
    'More rope strands share the load.',
  ],
  keyPointsEs: [
    'Una máquina simple permite usar menos fuerza a cambio de recorrer más distancia.',
    'Nunca crea energía adicional.',
    'Una palanca gira sobre un fulcro.',
    'Una rampa más larga necesita un empujón menor.',
    'Más ramales de cuerda comparten la carga.',
  ],
  glossary: [
    GlossaryTerm(
      en: 'Simple machine',
      es: 'Máquina simple',
      definitionEn: 'A device that changes the size or direction of a force.',
      definitionEs:
          'Un aparato que cambia el tamaño o la dirección de una fuerza.',
      audioEn: 'audio/en/simple_machine.mp3',
      audioEs: 'audio/es/maquina_simple.mp3',
    ),
    GlossaryTerm(
      en: 'Fulcrum',
      es: 'Fulcro',
      definitionEn: 'The fixed point a lever turns on.',
      definitionEs: 'El punto fijo sobre el que gira una palanca.',
      audioEn: 'audio/en/fulcrum.mp3',
      audioEs: 'audio/es/fulcro.mp3',
    ),
    GlossaryTerm(
      en: 'Effort',
      es: 'Esfuerzo',
      definitionEn: 'The force you apply to a machine.',
      definitionEs: 'La fuerza que aplicas a una máquina.',
      audioEn: 'audio/en/effort.mp3',
      audioEs: 'audio/es/esfuerzo.mp3',
    ),
    GlossaryTerm(
      en: 'Load',
      es: 'Carga',
      definitionEn: 'The weight the machine has to move.',
      definitionEs: 'El peso que la máquina tiene que mover.',
      audioEn: 'audio/en/load.mp3',
      audioEs: 'audio/es/carga.mp3',
    ),
    GlossaryTerm(
      en: 'Inclined plane',
      es: 'Plano inclinado',
      definitionEn: 'A sloping surface used to raise a load.',
      definitionEs:
          'Una superficie inclinada que se usa para elevar una carga.',
      audioEn: 'audio/en/inclined_plane.mp3',
      audioEs: 'audio/es/plano_inclinado.mp3',
    ),
  ],
  questions: [
    Question(
      id: 'q1',
      explanation:
          'Moving the fulcrum towards the load lengthens your side of the bar, so a smaller effort balances the same weight.',
      prompt: 'Moving a lever\'s fulcrum closer to the load makes lifting...',
      options: ['Easier', 'Harder', 'Impossible', 'Exactly the same'],
      answer: 0,
    ),
    Question(
      id: 'q2',
      explanation:
          'A longer ramp gives a gentler slope, so the push is smaller, but you have to push along a greater distance.',
      prompt: 'A longer ramp means you need...',
      options: [
        'Less force over more distance',
        'More force over less distance',
        'Less force over less distance',
        'More force over more distance',
      ],
      answer: 0,
    ),
    Question(
      id: 'q3',
      explanation:
          'Four strands share the weight equally, so each holds 200 divided by 4, which is 50 newtons.',
      prompt: 'A 200 N crate hangs from 4 rope strands. How hard do you pull?',
      options: ['50 N', '200 N', '800 N', '4 N'],
      answer: 0,
    ),
    Question(
      id: 'q4',
      explanation:
          'Machines never create energy. They let you use a smaller force, as long as you move it further.',
      kind: QuestionKind.blank,
      prompt: 'A simple machine trades force for ___.',
      options: ['distance', 'energy', 'mass', 'heat'],
      answer: 0,
    ),
    Question(
      id: 'q5',
      explanation:
          'A battery stores chemical energy. A simple machine only changes the size or direction of a force.',
      kind: QuestionKind.oddOneOut,
      prompt: 'Three of these are simple machines. Which one is not?',
      options: ['A battery', 'A lever', 'A ramp', 'A pulley'],
      answer: 0,
    ),
    Question(
      id: 'q6',
      explanation:
          'Each machine helps in its own way, and effort is the name for the force you supply.',
      kind: QuestionKind.match,
      prompt: 'Match each machine to how it helps.',
      points: 20,
      pairs: [
        MatchPair(left: 'Lever', right: 'Turns on a fulcrum'),
        MatchPair(left: 'Ramp', right: 'Spreads a lift out'),
        MatchPair(left: 'Pulley', right: 'Shares load across strands'),
        MatchPair(left: 'Effort', right: 'The force you apply'),
      ],
    ),
  ],
);
