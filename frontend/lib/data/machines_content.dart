import '../models/lesson.dart';
import 'practice_exercises.dart';

/// The Simple Machines lesson. Mirrors backend/seed/lessons/machines.json.
final machinesLesson = Lesson(
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
      promptEs:
          'Acercar el fulcro de una palanca a la carga hace que levantarla sea...',
      optionsEs: ['Más fácil', 'Más difícil', 'Imposible', 'Exactamente igual'],
      explanationEs:
          'Acercar el fulcro a la carga alarga el brazo del esfuerzo '
          'respecto al de la carga. Así, una fuerza menor puede equilibrar '
          'el mismo peso.',
      explanation:
          'Moving the fulcrum towards the load lengthens your side of the bar, so a smaller effort balances the same weight.',
      prompt: 'Moving a lever\'s fulcrum closer to the load makes lifting...',
      options: ['Easier', 'Harder', 'Impossible', 'Exactly the same'],
      answer: 0,
    ),
    Question(
      id: 'q2',
      promptEs:
          'Para alcanzar la misma altura y sin considerar la fricción, '
          'una rampa más larga requiere...',
      optionsEs: [
        'Menos fuerza a lo largo de más distancia',
        'Más fuerza a lo largo de menos distancia',
        'Menos fuerza a lo largo de menos distancia',
        'Más fuerza a lo largo de más distancia',
      ],
      explanationEs:
          'Una rampa más larga tiene una pendiente más suave. '
          'Necesitas menos fuerza, pero debes empujar a lo largo de '
          'una distancia mayor.',
      explanation:
          'A longer ramp gives a gentler slope, so the push is smaller, but you have to push along a greater distance.',
      prompt:
          'For the same height and ignoring friction, a longer ramp means you need...',
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
      promptEs:
          'En un sistema ideal de poleas, 4 ramales verticales sostienen '
          'una caja de 200 N. ¿Con qué fuerza debes tirar para '
          'elevarla a velocidad constante?',
      optionsEs: ['50 N', '200 N', '800 N', '4 N'],
      explanationEs:
          'Los cuatro ramales comparten el peso por igual. '
          'Cada uno sostiene 200 dividido entre 4 = 50 newtons.',
      explanation:
          'Four strands share the weight equally, so each holds 200 divided by 4, which is 50 newtons.',
      prompt:
          'In an ideal pulley system, 4 vertical rope strands support a '
          '200 N crate. How much pull lifts it at a steady speed?',
      options: ['50 N', '200 N', '800 N', '4 N'],
      answer: 0,
    ),
    Question(
      id: 'q4',
      promptEs: 'Una máquina simple cambia fuerza por ___.',
      optionsEs: ['distancia', 'energía', 'masa', 'calor'],
      explanationEs:
          'Una máquina permite usar menos fuerza si esta actúa a lo largo de más distancia.',
      explanation:
          'Machines never create energy. They let you use a smaller force, as long as you move it further.',
      kind: QuestionKind.blank,
      prompt: 'A simple machine trades force for ___.',
      options: ['distance', 'energy', 'mass', 'heat'],
      answer: 0,
    ),
    Question(
      id: 'q5',
      promptEs: 'Tres de estas son máquinas simples. ¿Cuál no lo es?',
      optionsEs: ['Una batería', 'Una palanca', 'Una rampa', 'Una polea'],
      explanationEs:
          'Una batería almacena energía química; una máquina simple cambia la magnitud o dirección de una fuerza.',
      explanation:
          'A battery stores chemical energy. A simple machine only changes the size or direction of a force.',
      kind: QuestionKind.oddOneOut,
      prompt: 'Three of these are simple machines. Which one is not?',
      options: ['A battery', 'A lever', 'A ramp', 'A pulley'],
      answer: 0,
    ),
    Question(
      id: 'q6',
      promptEs: 'Relaciona cada máquina o término con su función.',
      explanationEs:
          'Cada máquina ayuda de una forma; el esfuerzo es la fuerza de entrada que aplicas.',
      explanation:
          'Each machine helps in its own way, and effort is the name for the force you supply.',
      kind: QuestionKind.match,
      prompt: 'Match each machine to how it helps.',
      points: 20,
      pairs: [
        MatchPair(
          left: 'Lever',
          right: 'Turns on a fulcrum',
          leftEs: 'Palanca',
          rightEs: 'Gira sobre un fulcro',
        ),
        MatchPair(
          left: 'Ramp',
          right: 'Spreads a lift out',
          leftEs: 'Rampa',
          rightEs: 'Distribuye la subida a lo largo de más distancia',
        ),
        MatchPair(
          left: 'Pulley',
          right: 'Redirects a pull or shares load across strands',
          leftEs: 'Polea',
          rightEs: 'Redirige un tirón o reparte la carga entre ramales',
        ),
        MatchPair(
          left: 'Effort',
          right: 'The force you apply',
          leftEs: 'Esfuerzo',
          rightEs: 'La fuerza que aplicas',
        ),
      ],
    ),
    Question(
      id: 'q7',
      promptEs:
          '¿Cómo se llama el punto fijo alrededor del cual gira una palanca?',
      optionsEs: ['La carga', 'El fulcro', 'El esfuerzo', 'La rampa'],
      explanationEs:
          'El fulcro es el punto de apoyo de una palanca. '
          'La carga es lo que mueve y el esfuerzo es la fuerza de entrada.',
      prompt: 'What is the fixed point that a lever turns around called?',
      options: ['The load', 'The fulcrum', 'The effort', 'The ramp'],
      answer: 1,
      explanation:
          'The fulcrum is the pivot point of a lever. The load is what '
          'the lever moves, and the effort is the input force.',
    ),
    Question(
      id: 'q8',
      promptEs:
          'Una polea fija ideal eleva una carga. ¿Qué cambia principalmente?',
      optionsEs: [
        'La masa de la carga',
        'La cantidad de energía creada',
        'La dirección de la fuerza aplicada',
        'La intensidad de la gravedad',
      ],
      explanationEs:
          'Una polea fija cambia la dirección del tirón. '
          'Si no hay fricción, no reduce la fuerza necesaria.',
      prompt:
          'An ideal single fixed pulley lifts a load. What does it mainly change?',
      options: [
        'The mass of the load',
        'The amount of energy created',
        'The direction of the applied force',
        'The strength of gravity',
      ],
      answer: 2,
      explanation:
          'A single fixed pulley changes the direction of a pull. '
          'Ignoring friction, it does not reduce the force needed.',
    ),
    Question(
      id: 'q9',
      promptEs:
          'Cuando empujas con la mano una caja por una rampa, '
          '¿cómo se llama la fuerza de entrada?',
      optionsEs: ['Esfuerzo', 'Carga', 'Fulcro', 'Peso'],
      explanationEs:
          'El esfuerzo es la fuerza que se aplica a una máquina. '
          'La caja es la carga que esa fuerza ayuda a mover.',
      prompt:
          'When your hand pushes a box up a ramp, what is the input force called?',
      options: ['Effort', 'Load', 'Fulcrum', 'Weight'],
      answer: 0,
      explanation:
          'Effort is the force supplied to a machine. The box is the '
          'load that the effort helps move.',
    ),
    Question(
      id: 'q10',
      promptEs:
          'El fulcro y la carga de una palanca no cambian de lugar. '
          '¿Dónde debes empujar para levantar la carga con menos fuerza?',
      optionsEs: [
        'Directamente sobre el fulcro',
        'Más cerca del fulcro',
        'Sobre la carga en lugar del extremo del esfuerzo',
        'Más lejos del fulcro, en el extremo del esfuerzo',
      ],
      explanationEs:
          'Empujar más lejos del fulcro alarga el brazo del esfuerzo. '
          'Un brazo más largo necesita menos fuerza para levantar '
          'la misma carga.',
      prompt:
          'A lever\'s fulcrum and load stay in the same positions. '
          'Where should you push to lift the load with less force?',
      options: [
        'Directly on the fulcrum',
        'Closer to the fulcrum',
        'On the load instead of the effort end',
        'Farther from the fulcrum on the effort end',
      ],
      answer: 3,
      explanation:
          'Pushing farther from the fulcrum increases the effort arm. '
          'The longer effort arm needs less force to lift the same load.',
    ),
    Question(
      id: 'q11',
      promptEs:
          'Una polea ideal tiene 2 ramales verticales que sostienen la '
          'carga. ¿Cuánta cuerda debes tirar para elevarla 1 metro?',
      optionsEs: ['0,5 metro', '1 metro', '2 metros', '4 metros'],
      explanationEs:
          'Dos ramales de apoyo reducen la fuerza de entrada a la mitad, '
          'pero debes tirar de la cuerda el doble de la distancia '
          'que sube la carga.',
      prompt:
          'An ideal pulley has 2 vertical rope sections supporting its '
          'load. How much rope must you pull to lift the load 1 metre?',
      options: ['0.5 metre', '1 metre', '2 metres', '4 metres'],
      answer: 2,
      explanation:
          'Two supporting rope sections reduce the input force by a '
          'factor of two, but the input rope must move twice as far as the load.',
    ),
    Question(
      id: 'q12',
      promptEs:
          'En una máquina real, ¿por qué el trabajo útil de salida '
          'puede ser menor que el trabajo de entrada?',
      optionsEs: [
        'La energía se destruye dentro de la máquina',
        'Parte de la energía se convierte en calor por la fricción',
        'La máquina crea energía adicional',
        'La carga pierde toda su masa',
      ],
      explanationEs:
          'La fricción transfiere parte de la energía de entrada '
          'al calor en lugar de al trabajo útil. La energía total '
          'se sigue conservando.',
      prompt:
          'In a real machine, why can useful output work be less than input work?',
      options: [
        'Energy is destroyed inside the machine',
        'Some energy becomes heat because of friction',
        'The machine creates additional energy',
        'The load loses all of its mass',
      ],
      answer: 1,
      explanation:
          'Friction transfers some input energy to heat rather than '
          'useful work. Total energy is still conserved.',
    ),
    Question(
      id: 'q13',
      promptEs:
          'Un estante está a 1 metro de altura. Las rampas no pueden '
          'medir más de 3 metros. Sin fricción, ¿cuál eleva una caja '
          'con el menor empujón?',
      optionsEs: [
        'Una rampa de 2 metros',
        'Una rampa de 4 metros',
        'Una rampa de 6 metros',
        'Una rampa de 3 metros',
      ],
      explanationEs:
          'La rampa de 3 metros es la más larga permitida, por lo '
          'que necesita menos fuerza que la de 2 metros. Las rampas '
          'de 4 y 6 metros superan el límite de longitud.',
      prompt:
          'A shelf is 1 metre high. Ramps may be no longer than 3 metres. '
          'Ignoring friction, which ramp raises a box with the smallest push?',
      options: [
        'A 2-metre ramp',
        'A 4-metre ramp',
        'A 6-metre ramp',
        'A 3-metre ramp',
      ],
      answer: 3,
      explanation:
          'The 3-metre ramp is the longest allowed ramp, so it needs '
          'less force than the 2-metre ramp. The 4- and 6-metre ramps break the length limit.',
    ),
    ...machinesPracticeQuestions,
  ],
);
