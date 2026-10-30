import '../models/lesson.dart';

// Each record keeps an English choice beside its Spanish translation.
Question _choice({
  required String id,
  required QuestionKind kind,
  required String prompt,
  required String promptEs,
  required List<(String, String)> choices,
  required int answer,
  required String explanation,
  required String explanationEs,
}) {
  if (kind == QuestionKind.match ||
      choices.length != 4 ||
      answer < 0 ||
      answer >= choices.length) {
    throw ArgumentError('Invalid choice exercise: $id');
  }
  if (kind == QuestionKind.blank &&
      (prompt.split('___').length != 2 || promptEs.split('___').length != 2)) {
    throw ArgumentError(
      'Blank exercise must contain one gap per language: $id',
    );
  }
  return Question(
    id: id,
    kind: kind,
    prompt: prompt,
    promptEs: promptEs,
    options: [for (final choice in choices) choice.$1],
    optionsEs: [for (final choice in choices) choice.$2],
    answer: answer,
    explanation: explanation,
    explanationEs: explanationEs,
  );
}

// Pair records contain English/Spanish terms, then English/Spanish meanings.
Question _matching({
  required String id,
  required String prompt,
  required String promptEs,
  required List<(String, String, String, String)> entries,
  required String explanation,
  required String explanationEs,
}) {
  if (entries.length != 4 ||
      entries.map((entry) => entry.$1).toSet().length != entries.length ||
      entries.map((entry) => entry.$2).toSet().length != entries.length ||
      entries.map((entry) => entry.$3).toSet().length != entries.length ||
      entries.map((entry) => entry.$4).toSet().length != entries.length) {
    throw ArgumentError(
      'Matching exercise requires four unambiguous pairs: $id',
    );
  }
  return Question(
    id: id,
    kind: QuestionKind.match,
    prompt: prompt,
    promptEs: promptEs,
    points: 20,
    pairs: [
      for (final entry in entries)
        MatchPair(
          left: entry.$1,
          leftEs: entry.$2,
          right: entry.$3,
          rightEs: entry.$4,
        ),
    ],
    explanation: explanation,
    explanationEs: explanationEs,
  );
}

final motionPracticeQuestions = <Question>[
  _choice(
    id: 'blank-2',
    kind: QuestionKind.blank,
    prompt: 'A change in position is called ___.',
    promptEs: 'Un cambio de posición se llama ___.',
    choices: [
      ('motion', 'movimiento'),
      ('friction', 'fricción'),
      ('mass', 'masa'),
      ('weight', 'peso'),
    ],
    answer: 0,
    explanation:
        'Motion means that position changes relative to a reference point.',
    explanationEs:
        'El movimiento es un cambio de posición respecto a un punto de referencia.',
  ),
  _choice(
    id: 'blank-3',
    kind: QuestionKind.blank,
    prompt: 'A fixed object used to describe position is a ___.',
    promptEs: 'Un objeto fijo usado para describir la posición es un ___.',
    choices: [
      ('reference point', 'punto de referencia'),
      ('force', 'fuerza'),
      ('pulley', 'polea'),
      ('thermometer', 'termómetro'),
    ],
    answer: 0,
    explanation:
        'A reference point lets us describe where something is and whether it moves.',
    explanationEs:
        'Un punto de referencia permite describir dónde está algo y si se mueve.',
  ),
  _choice(
    id: 'blank-4',
    kind: QuestionKind.blank,
    prompt: 'A car that gains speed is ___.',
    promptEs: 'Un auto que aumenta su velocidad está ___.',
    choices: [
      ('speeding up', 'acelerando'),
      ('slowing down', 'desacelerando'),
      ('at rest', 'en reposo'),
      ('stopping', 'deteniéndose'),
    ],
    answer: 0,
    explanation: 'Speeding up means that speed increases.',
    explanationEs: 'Acelerar, en este caso, significa aumentar la velocidad.',
  ),
  _choice(
    id: 'blank-5',
    kind: QuestionKind.blank,
    prompt: 'A car that loses speed is ___.',
    promptEs: 'Un auto que reduce su velocidad está ___.',
    choices: [
      ('slowing down', 'desacelerando'),
      ('speeding up', 'acelerando'),
      ('parked', 'estacionado'),
      ('gaining mass', 'ganando masa'),
    ],
    answer: 0,
    explanation:
        'Slowing down means that speed decreases; the car can still be moving.',
    explanationEs:
        'Desacelerar significa reducir la velocidad; el auto todavía puede moverse.',
  ),
  _choice(
    id: 'blank-6',
    kind: QuestionKind.blank,
    prompt:
        'On the same distance-time axes, a steeper upward line means ___ speed.',
    promptEs:
        'En los mismos ejes de distancia y tiempo, una línea ascendente más inclinada indica una velocidad ___.',
    choices: [
      ('higher', 'mayor'),
      ('lower', 'menor'),
      ('zero', 'nula'),
      ('the same', 'igual'),
    ],
    answer: 0,
    explanation: 'A steeper line shows more distance covered in the same time.',
    explanationEs:
        'Una mayor pendiente indica más distancia recorrida en el mismo tiempo.',
  ),
  _choice(
    id: 'blank-7',
    kind: QuestionKind.blank,
    prompt: 'An object not moving relative to its reference point is at ___.',
    promptEs:
        'Un objeto que no se mueve respecto a su punto de referencia está en ___.',
    choices: [
      ('rest', 'reposo'),
      ('speed', 'velocidad'),
      ('force', 'fuerza'),
      ('distance', 'distancia'),
    ],
    answer: 0,
    explanation:
        'At rest describes an unchanged position relative to the chosen reference point.',
    explanationEs:
        'Estar en reposo significa no cambiar de posición respecto al punto de referencia elegido.',
  ),
  _choice(
    id: 'blank-8',
    kind: QuestionKind.blank,
    prompt:
        'At 3 metres per second for 4 seconds, a toy car travels ___ metres.',
    promptEs:
        'Un carrito que avanza a 3 metros por segundo durante 4 segundos recorre ___ metros.',
    choices: [('12', '12'), ('7', '7'), ('1', '1'), ('16', '16')],
    answer: 0,
    explanation:
        'At constant speed, distance is speed times time: 3 times 4 = 12.',
    explanationEs:
        'A velocidad constante, la distancia es velocidad por tiempo: 3 por 4 = 12.',
  ),
  _choice(
    id: 'blank-9',
    kind: QuestionKind.blank,
    prompt: 'To measure elapsed time, use a ___.',
    promptEs: 'Para medir el tiempo transcurrido, usa un ___.',
    choices: [
      ('stopwatch', 'cronómetro'),
      ('metre stick', 'metro de medir'),
      ('balance', 'instrumento para comparar masas'),
      ('spring scale', 'dinamómetro'),
    ],
    answer: 0,
    explanation: 'A stopwatch measures how long an event takes.',
    explanationEs: 'Un cronómetro mide cuánto dura un suceso.',
  ),
  _choice(
    id: 'blank-10',
    kind: QuestionKind.blank,
    prompt: 'Complete the English sentence: The bicycle ___ moving.',
    promptEs: 'Completa la oración: La bicicleta ___ moviéndose.',
    choices: [
      ('is', 'está'),
      ('are', 'están'),
      ('am', 'estoy'),
      ('be', 'estar'),
    ],
    answer: 0,
    explanation: 'The bicycle is singular, so use is: The bicycle is moving.',
    explanationEs:
        'La bicicleta es singular. En inglés se usa is: The bicycle is moving.',
  ),
  _choice(
    id: 'odd-2',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which word does NOT describe motion?',
    promptEs: '¿Qué palabra NO describe el movimiento?',
    choices: [
      ('moving', 'moviéndose'),
      ('stopped', 'detenido'),
      ('speeding up', 'acelerando'),
      ('purple', 'morado'),
    ],
    answer: 3,
    explanation: 'Purple describes colour, not how an object moves.',
    explanationEs: 'Morado describe un color, no cómo se mueve un objeto.',
  ),
  _choice(
    id: 'odd-3',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT a unit of time?',
    promptEs: '¿Cuál NO es una unidad de tiempo?',
    choices: [
      ('seconds', 'segundos'),
      ('minutes', 'minutos'),
      ('hours', 'horas'),
      ('kilograms', 'kilogramos'),
    ],
    answer: 3,
    explanation:
        'Kilograms measure mass; seconds, minutes, and hours measure time.',
    explanationEs:
        'Los kilogramos miden masa; los segundos, minutos y horas miden tiempo.',
  ),
  _choice(
    id: 'odd-4',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT a unit of distance?',
    promptEs: '¿Cuál NO es una unidad de distancia?',
    choices: [
      ('metres', 'metros'),
      ('kilometres', 'kilómetros'),
      ('centimetres', 'centímetros'),
      ('seconds', 'segundos'),
    ],
    answer: 3,
    explanation: 'Seconds measure time, not distance.',
    explanationEs: 'Los segundos miden tiempo, no distancia.',
  ),
  _choice(
    id: 'odd-5',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which measurement is NOT a speed?',
    promptEs: '¿Qué medición NO es una velocidad?',
    choices: [
      ('2 metres per second', '2 metros por segundo'),
      ('5 kilometres per hour', '5 kilómetros por hora'),
      ('3 miles per hour', '3 millas por hora'),
      ('4 metres', '4 metros'),
    ],
    answer: 3,
    explanation: 'Four metres is a distance without a time interval.',
    explanationEs: 'Cuatro metros es una distancia sin un intervalo de tiempo.',
  ),
  _choice(
    id: 'odd-6',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which phrase does NOT mean increasing speed?',
    promptEs: '¿Qué frase NO significa aumentar la velocidad?',
    choices: [
      ('gaining speed', 'ganar velocidad'),
      ('accelerating to a faster speed', 'acelerar hasta una velocidad mayor'),
      ('speeding up', 'ir cada vez más rápido'),
      ('slowing down', 'reducir la velocidad'),
    ],
    answer: 3,
    explanation: 'Slowing down is the opposite of increasing speed.',
    explanationEs: 'Reducir la velocidad es lo contrario de aumentarla.',
  ),
  _choice(
    id: 'odd-7',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT at rest relative to the road?',
    promptEs: '¿Cuál NO está en reposo respecto a la carretera?',
    choices: [
      ('a parked car', 'un auto estacionado'),
      ('a stopped bus', 'un autobús detenido'),
      ('a stationary bicycle', 'una bicicleta inmóvil'),
      ('a moving train', 'un tren en marcha'),
    ],
    answer: 3,
    explanation: 'The moving train changes position relative to the road.',
    explanationEs:
        'El tren en marcha cambia de posición respecto a la carretera.',
  ),
  _choice(
    id: 'odd-8',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT needed to calculate average speed?',
    promptEs: '¿Qué NO se necesita para calcular la velocidad media?',
    choices: [
      ('total distance', 'distancia total'),
      ('elapsed time', 'tiempo transcurrido'),
      ('consistent units', 'unidades coherentes'),
      ('mass', 'masa'),
    ],
    answer: 3,
    explanation:
        'Average speed uses distance and time in consistent units, not mass.',
    explanationEs:
        'La velocidad media usa distancia y tiempo con unidades coherentes, no masa.',
  ),
  _choice(
    id: 'odd-9',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which phrase does NOT compare speed?',
    promptEs: '¿Qué frase NO compara la velocidad?',
    choices: [
      ('faster than', 'más rápido que'),
      ('slower than', 'más lento que'),
      ('as fast as', 'tan rápido como'),
      ('heavier than', 'más pesado que'),
    ],
    answer: 3,
    explanation: 'Heavier than compares weight, not speed.',
    explanationEs: 'Más pesado que compara el peso, no la velocidad.',
  ),
  _choice(
    id: 'odd-10',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT used to measure motion in this lesson?',
    promptEs: '¿Qué NO se usa para medir el movimiento en esta lección?',
    choices: [
      ('stopwatch', 'cronómetro'),
      ('metre stick', 'metro de medir'),
      ('speedometer', 'velocímetro'),
      ('thermometer', 'termómetro'),
    ],
    answer: 3,
    explanation:
        'A thermometer measures temperature rather than distance, time, or speed.',
    explanationEs:
        'Un termómetro mide temperatura, no distancia, tiempo ni velocidad.',
  ),
  _matching(
    id: 'match-2',
    prompt: 'Match motion measurements to their meanings.',
    promptEs: 'Relaciona las mediciones del movimiento con sus significados.',
    entries: [
      (
        'Distance',
        'Distancia',
        'How far something travels',
        'Qué tan lejos se desplaza algo',
      ),
      ('Time', 'Tiempo', 'How long an event takes', 'Cuánto dura un suceso'),
      (
        'Speed',
        'Velocidad',
        'Distance covered per unit of time',
        'Distancia recorrida por unidad de tiempo',
      ),
      ('Position', 'Posición', 'Where an object is', 'Dónde está un objeto'),
    ],
    explanation:
        'Distance, time, speed, and position describe different aspects of motion.',
    explanationEs:
        'Distancia, tiempo, velocidad y posición describen aspectos distintos del movimiento.',
  ),
  _matching(
    id: 'match-3',
    prompt: 'Match movement verbs to their meanings.',
    promptEs: 'Relaciona los verbos de movimiento con sus significados.',
    entries: [
      ('Start', 'Empezar', 'Begin moving', 'Comenzar a moverse'),
      ('Stop', 'Parar', 'Finish moving', 'Dejar de moverse'),
      ('Speed up', 'Acelerar', 'Increase speed', 'Aumentar la velocidad'),
      ('Slow down', 'Desacelerar', 'Decrease speed', 'Reducir la velocidad'),
    ],
    explanation: 'These verbs describe starting, stopping, and changing speed.',
    explanationEs:
        'Estos verbos describen cómo empezar, parar y cambiar la velocidad.',
  ),
  _matching(
    id: 'match-4',
    prompt: 'Match speed comparisons to their meanings.',
    promptEs: 'Relaciona las comparaciones de velocidad con sus significados.',
    entries: [
      ('Faster', 'Más rápido', 'A greater speed', 'Una velocidad mayor'),
      ('Slower', 'Más lento', 'A smaller speed', 'Una velocidad menor'),
      ('Same speed', 'Misma velocidad', 'Equal speeds', 'Velocidades iguales'),
      (
        'At rest',
        'En reposo',
        'No motion relative to a reference point',
        'Sin movimiento respecto a un punto de referencia',
      ),
    ],
    explanation:
        'Faster and slower compare speeds; at rest depends on the reference point.',
    explanationEs:
        'Más rápido y más lento comparan velocidades; el reposo depende del punto de referencia.',
  ),
  _matching(
    id: 'match-5',
    prompt: 'Match each trip to its average speed.',
    promptEs: 'Relaciona cada recorrido con su velocidad media.',
    entries: [
      (
        '20 metres in 5 seconds',
        '20 metros en 5 segundos',
        '4 metres per second',
        '4 metros por segundo',
      ),
      (
        '30 metres in 6 seconds',
        '30 metros en 6 segundos',
        '5 metres per second',
        '5 metros por segundo',
      ),
      (
        '18 metres in 3 seconds',
        '18 metros en 3 segundos',
        '6 metres per second',
        '6 metros por segundo',
      ),
      (
        '21 metres in 3 seconds',
        '21 metros en 3 segundos',
        '7 metres per second',
        '7 metros por segundo',
      ),
    ],
    explanation:
        'Divide each distance by its elapsed time to find the average speed.',
    explanationEs:
        'Divide cada distancia entre el tiempo transcurrido para calcular la velocidad media.',
  ),
  _matching(
    id: 'match-6',
    prompt: 'On the same distance-time axes, match each line to its meaning.',
    promptEs:
        'En los mismos ejes de distancia y tiempo, relaciona cada línea con su significado.',
    entries: [
      (
        'Horizontal line',
        'Línea horizontal',
        'No increase in distance',
        'La distancia no aumenta',
      ),
      (
        'Straight rising line',
        'Línea recta ascendente',
        'Steady nonzero speed',
        'Velocidad constante distinta de cero',
      ),
      (
        'Steeper rising line',
        'Línea ascendente más inclinada',
        'Higher speed than a less steep line',
        'Mayor velocidad que una línea menos inclinada',
      ),
      (
        'Curve becoming steeper',
        'Curva cada vez más inclinada',
        'Speed increasing over time',
        'Velocidad que aumenta con el tiempo',
      ),
    ],
    explanation: 'The steepness of a distance-time graph indicates speed.',
    explanationEs:
        'La pendiente de una gráfica de distancia y tiempo indica la velocidad.',
  ),
  _matching(
    id: 'match-7',
    prompt: 'Match measurement tools and reference ideas to their uses.',
    promptEs:
        'Relaciona los instrumentos y conceptos de referencia con sus usos.',
    entries: [
      ('Metre stick', 'Metro de medir', 'Measures distance', 'Mide distancia'),
      (
        'Stopwatch',
        'Cronómetro',
        'Measures elapsed time',
        'Mide el tiempo transcurrido',
      ),
      (
        'Speedometer',
        'Velocímetro',
        'Shows speed now',
        'Muestra la velocidad actual',
      ),
      (
        'Reference point',
        'Punto de referencia',
        'Used to describe position',
        'Se usa para describir la posición',
      ),
    ],
    explanation:
        'Choose a tool or reference that measures the quantity you need.',
    explanationEs:
        'Elige el instrumento o la referencia correspondiente a lo que necesitas medir.',
  ),
  _matching(
    id: 'match-8',
    prompt: 'Match English motion phrases to their meanings.',
    promptEs: 'Relaciona las frases de movimiento con sus significados.',
    entries: [
      (
        'Is moving',
        'Se está moviendo',
        'Its position is changing',
        'Su posición está cambiando',
      ),
      (
        'Is slowing down',
        'Está desacelerando',
        'Its speed is decreasing',
        'Su velocidad está disminuyendo',
      ),
      (
        'Is at rest',
        'Está en reposo',
        'Its position stays the same relative to the reference',
        'Su posición no cambia respecto a la referencia',
      ),
      (
        'Is speeding up',
        'Está acelerando',
        'Its speed is increasing',
        'Su velocidad está aumentando',
      ),
    ],
    explanation: 'The verb is agrees with a singular subject such as the car.',
    explanationEs:
        'El verbo is concuerda con un sujeto singular, como the car.',
  ),
  _matching(
    id: 'match-9',
    prompt: 'Match constant-speed expressions to the quantity they give.',
    promptEs:
        'Relaciona las expresiones de velocidad constante con la magnitud que calculan.',
    entries: [
      ('Distance ÷ time', 'Distancia ÷ tiempo', 'Speed', 'Velocidad'),
      ('Speed × time', 'Velocidad × tiempo', 'Distance', 'Distancia'),
      (
        'Distance ÷ speed',
        'Distancia ÷ velocidad',
        'Elapsed time',
        'Tiempo transcurrido',
      ),
      ('Change in position', 'Cambio de posición', 'Motion', 'Movimiento'),
    ],
    explanation:
        'Use consistent units and a nonzero speed when dividing distance by speed.',
    explanationEs:
        'Usa unidades coherentes y una velocidad distinta de cero al dividir distancia entre velocidad.',
  ),
  _matching(
    id: 'match-10',
    prompt: 'Match each bus situation to its motion description.',
    promptEs:
        'Relaciona cada situación del autobús con su descripción de movimiento.',
    entries: [
      (
        'A parked bus',
        'Un autobús estacionado',
        'At rest relative to the road',
        'En reposo respecto a la carretera',
      ),
      (
        'A bus gaining speed after a stop',
        'Un autobús que gana velocidad al salir',
        'Speeding up',
        'Acelerando',
      ),
      (
        'A bus braking before a stop',
        'Un autobús que frena antes de parar',
        'Slowing down',
        'Desacelerando',
      ),
      (
        'A bus covering equal distances in equal times',
        'Un autobús que recorre distancias iguales en tiempos iguales',
        'Steady average speed in each interval',
        'Velocidad media constante en cada intervalo',
      ),
    ],
    explanation:
        'Describe the motion you observe rather than guessing from the type of vehicle.',
    explanationEs:
        'Describe el movimiento observado en lugar de adivinarlo por el tipo de vehículo.',
  ),
];

final forcesPracticeQuestions = <Question>[
  _choice(
    id: 'blank-2',
    kind: QuestionKind.blank,
    prompt: 'A force is a push or a ___.',
    promptEs: 'Una fuerza es un empujón o un ___.',
    choices: [
      ('pull', 'tirón'),
      ('speed', 'tipo de velocidad'),
      ('temperature', 'cambio de temperatura'),
      ('mass', 'valor de masa'),
    ],
    answer: 0,
    explanation:
        'Push and pull are the two everyday words used to describe a force.',
    explanationEs:
        'Empujón y tirón son dos palabras cotidianas para describir una fuerza.',
  ),
  _choice(
    id: 'blank-3',
    kind: QuestionKind.blank,
    prompt: 'Equal opposite forces that cancel are called ___ forces.',
    promptEs: 'Las fuerzas opuestas que se cancelan se llaman fuerzas ___.',
    choices: [
      ('balanced', 'equilibradas'),
      ('unbalanced', 'desequilibradas'),
      ('increasing', 'crecientes'),
      ('rotating', 'giratorias'),
    ],
    answer: 0,
    explanation: 'Balanced forces have a net force of zero.',
    explanationEs:
        'Las fuerzas equilibradas tienen una fuerza neta igual a cero.',
  ),
  _choice(
    id: 'blank-4',
    kind: QuestionKind.blank,
    prompt:
        'With 10 N right and 4 N left, the net force is ___ N to the right.',
    promptEs:
        'Con 10 N a la derecha y 4 N a la izquierda, la fuerza neta es ___ N a la derecha.',
    choices: [('6', '6'), ('14', '14'), ('4', '4'), ('0', '0')],
    answer: 0,
    explanation: 'Subtract opposite forces: 10 minus 4 = 6 N to the right.',
    explanationEs:
        'Resta las fuerzas opuestas: 10 menos 4 = 6 N hacia la derecha.',
  ),
  _choice(
    id: 'blank-5',
    kind: QuestionKind.blank,
    prompt: 'The force between surfaces that opposes sliding is ___.',
    promptEs:
        'La fuerza entre superficies que se opone al deslizamiento es la ___.',
    choices: [
      ('friction', 'fricción'),
      ('gravity', 'gravedad'),
      ('speed', 'velocidad'),
      ('mass', 'masa'),
    ],
    answer: 0,
    explanation:
        'Friction resists relative sliding between surfaces in contact.',
    explanationEs:
        'La fricción se opone al deslizamiento relativo entre superficies en contacto.',
  ),
  _choice(
    id: 'blank-6',
    kind: QuestionKind.blank,
    prompt: 'Gravity is an example of a ___ force.',
    promptEs: 'La gravedad es un ejemplo de fuerza ___.',
    choices: [
      ('non-contact', 'sin contacto'),
      ('contact-only', 'solo de contacto'),
      ('friction-only', 'solo de fricción'),
      ('zero', 'nula'),
    ],
    answer: 0,
    explanation: 'Gravity acts between masses without requiring them to touch.',
    explanationEs: 'La gravedad actúa entre masas sin que tengan que tocarse.',
  ),
  _choice(
    id: 'blank-7',
    kind: QuestionKind.blank,
    prompt:
        'For the same nonzero net force, a cart with less mass has ___ acceleration.',
    promptEs:
        'Con la misma fuerza neta distinta de cero, un carrito de menor masa tiene una aceleración ___.',
    choices: [
      ('greater', 'mayor'),
      ('smaller', 'menor'),
      ('zero', 'nula'),
      ('the same', 'igual'),
    ],
    answer: 0,
    explanation: 'Less mass means greater acceleration for the same net force.',
    explanationEs:
        'Una masa menor produce mayor aceleración con la misma fuerza neta.',
  ),
  _choice(
    id: 'blank-8',
    kind: QuestionKind.blank,
    prompt: 'Complete the English sentence: The hands ___ pushing the box.',
    promptEs: 'Completa la oración: Las manos ___ empujando la caja.',
    choices: [
      ('are', 'están'),
      ('is', 'está'),
      ('am', 'estoy'),
      ('be', 'estar'),
    ],
    answer: 0,
    explanation: 'Hands is plural, so use are rather than is.',
    explanationEs: 'Hands es plural; por eso se usa are y no is.',
  ),
  _choice(
    id: 'blank-9',
    kind: QuestionKind.blank,
    prompt: 'A parachute slows a fall by increasing air ___.',
    promptEs: 'Un paracaídas frena una caída al aumentar la ___ del aire.',
    choices: [
      ('resistance', 'resistencia'),
      ('mass', 'masa'),
      ('gravity', 'gravedad'),
      ('temperature', 'temperatura'),
    ],
    answer: 0,
    explanation:
        'An open parachute increases the force from air opposing the fall.',
    explanationEs:
        'Un paracaídas abierto aumenta la fuerza del aire que se opone a la caída.',
  ),
  _choice(
    id: 'blank-10',
    kind: QuestionKind.blank,
    prompt: 'The wall pushes back in the ___ direction to the student\'s push.',
    promptEs: 'La pared empuja en sentido ___ al empujón del estudiante.',
    choices: [
      ('opposite', 'opuesto'),
      ('same', 'igual'),
      ('zero', 'nulo'),
      ('bright', 'brillante'),
    ],
    answer: 0,
    explanation:
        'Action and reaction forces are equal and opposite and act on different objects.',
    explanationEs:
        'La acción y la reacción son fuerzas iguales y opuestas que actúan sobre objetos distintos.',
  ),
  _choice(
    id: 'odd-2',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT a contact force?',
    promptEs: '¿Cuál NO es una fuerza de contacto?',
    choices: [
      ('friction', 'fricción'),
      ('a hand pushing a box', 'una mano que empuja una caja'),
      ('tension in a rope', 'tensión en una cuerda'),
      ('gravity', 'gravedad'),
    ],
    answer: 3,
    explanation:
        'Gravity can act without contact; the other interactions require touching materials.',
    explanationEs:
        'La gravedad actúa sin contacto; las otras interacciones requieren materiales que se toquen.',
  ),
  _choice(
    id: 'odd-3',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT a unit or symbol used for force?',
    promptEs: '¿Cuál NO es una unidad o símbolo de fuerza?',
    choices: [
      ('N', 'N'),
      ('newtons', 'newtons'),
      ('kilonewtons', 'kilonewtons'),
      ('kilograms', 'kilogramos'),
    ],
    answer: 3,
    explanation:
        'Kilograms measure mass. N means newtons, and a kilonewton is 1000 newtons.',
    explanationEs:
        'Los kilogramos miden masa. N significa newtons y un kilonewton equivale a 1000 newtons.',
  ),
  _choice(
    id: 'odd-4',
    kind: QuestionKind.oddOneOut,
    prompt:
        'For a book sliding horizontally on a flat table, which force does NOT oppose the horizontal motion?',
    promptEs:
        'Para un libro que se desliza horizontalmente en una mesa plana, ¿qué fuerza NO se opone a ese movimiento horizontal?',
    choices: [
      ('sliding friction', 'fricción de deslizamiento'),
      ('friction from a rough surface', 'fricción de una superficie rugosa'),
      ('air resistance', 'resistencia del aire'),
      ('Earth\'s downward gravity', 'la gravedad terrestre hacia abajo'),
    ],
    answer: 3,
    explanation:
        'Gravity acts downward, not opposite the horizontal motion on a level table.',
    explanationEs:
        'La gravedad actúa hacia abajo, no en sentido contrario al movimiento horizontal en una mesa nivelada.',
  ),
  _choice(
    id: 'odd-5',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which force pair does NOT have zero net horizontal force?',
    promptEs:
        '¿Qué pareja de fuerzas NO tiene fuerza neta horizontal igual a cero?',
    choices: [
      ('4 N left and 4 N right', '4 N a la izquierda y 4 N a la derecha'),
      ('6 N left and 6 N right', '6 N a la izquierda y 6 N a la derecha'),
      ('8 N left and 8 N right', '8 N a la izquierda y 8 N a la derecha'),
      ('6 N right and 2 N left', '6 N a la derecha y 2 N a la izquierda'),
    ],
    answer: 3,
    explanation: 'The last pair has a net force of 4 N to the right.',
    explanationEs:
        'La última pareja tiene una fuerza neta de 4 N hacia la derecha.',
  ),
  _choice(
    id: 'odd-6',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT a push or pull applied by a person?',
    promptEs: '¿Cuál NO es un empujón o tirón aplicado por una persona?',
    choices: [
      ('pushing a door', 'empujar una puerta'),
      ('pulling a wagon', 'tirar de un carrito'),
      ('kicking a ball', 'patear una pelota'),
      ('Earth attracting an apple', 'la Tierra atrayendo una manzana'),
    ],
    answer: 3,
    explanation:
        'Earth attracts the apple through gravity, not a person\'s applied force.',
    explanationEs:
        'La Tierra atrae la manzana por gravedad, no por una fuerza aplicada por una persona.',
  ),
  _choice(
    id: 'odd-7',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which word is NOT a direction?',
    promptEs: '¿Qué palabra NO indica una dirección?',
    choices: [
      ('left', 'izquierda'),
      ('right', 'derecha'),
      ('upward', 'hacia arriba'),
      ('newton', 'newton'),
    ],
    answer: 3,
    explanation: 'A newton is a force unit, not a direction.',
    explanationEs: 'Un newton es una unidad de fuerza, no una dirección.',
  ),
  _choice(
    id: 'odd-8',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which action does NOT increase a cart\'s mass?',
    promptEs: '¿Qué acción NO aumenta la masa de un carrito?',
    choices: [
      ('adding books', 'añadir libros'),
      ('adding a box', 'añadir una caja'),
      ('adding weights', 'añadir pesas'),
      ('pushing harder', 'empujar con más fuerza'),
    ],
    answer: 3,
    explanation:
        'A stronger push changes force, not the amount of matter in the cart.',
    explanationEs:
        'Un empujón mayor cambia la fuerza, no la cantidad de materia del carrito.',
  ),
  _choice(
    id: 'odd-9',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which phrase does NOT describe balanced forces?',
    promptEs: '¿Qué frase NO describe fuerzas equilibradas?',
    choices: [
      ('equal and opposite', 'iguales y opuestas'),
      ('zero net force', 'fuerza neta igual a cero'),
      ('no change in velocity', 'sin cambio de velocidad'),
      ('a greater force on one side', 'una fuerza mayor en un lado'),
    ],
    answer: 3,
    explanation: 'A greater force on one side makes the forces unbalanced.',
    explanationEs:
        'Una fuerza mayor en un lado produce fuerzas desequilibradas.',
  ),
  _choice(
    id: 'odd-10',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which action does NOT make a fair test of push strength?',
    promptEs:
        '¿Qué acción NO permite una prueba justa de la intensidad del empujón?',
    choices: [
      ('keeping cart mass the same', 'mantener la misma masa del carrito'),
      ('using the same track', 'usar la misma pista'),
      ('keeping push duration the same', 'mantener la duración del empujón'),
      (
        'changing both cart mass and push strength',
        'cambiar la masa y la intensidad del empujón',
      ),
    ],
    answer: 3,
    explanation:
        'Changing mass and force together makes it difficult to identify the effect of force alone.',
    explanationEs:
        'Cambiar masa y fuerza a la vez dificulta identificar el efecto de la fuerza por sí sola.',
  ),
  _matching(
    id: 'match-2',
    prompt: 'Match force types to their descriptions.',
    promptEs: 'Relaciona los tipos de fuerza con sus descripciones.',
    entries: [
      (
        'Gravity',
        'Gravedad',
        'Attraction between masses',
        'Atracción entre masas',
      ),
      (
        'Friction',
        'Fricción',
        'Resistance to sliding between surfaces',
        'Resistencia al deslizamiento entre superficies',
      ),
      (
        'Air resistance',
        'Resistencia del aire',
        'Force from air opposing motion',
        'Fuerza del aire que se opone al movimiento',
      ),
      (
        'Applied force',
        'Fuerza aplicada',
        'A direct push or pull from an object or person',
        'Un empujón o tirón directo de una persona u objeto',
      ),
    ],
    explanation: 'Name a force by the interaction that produces it.',
    explanationEs: 'Identifica una fuerza por la interacción que la produce.',
  ),
  _matching(
    id: 'match-3',
    prompt: 'Match force vocabulary to definitions.',
    promptEs: 'Relaciona el vocabulario de fuerzas con sus definiciones.',
    entries: [
      (
        'Net force',
        'Fuerza neta',
        'The total force after combining all forces',
        'La fuerza total al combinar todas las fuerzas',
      ),
      (
        'Balanced forces',
        'Fuerzas equilibradas',
        'Forces that combine to zero',
        'Fuerzas cuya suma es cero',
      ),
      (
        'Unbalanced forces',
        'Fuerzas desequilibradas',
        'Forces that produce a nonzero total',
        'Fuerzas que producen una suma distinta de cero',
      ),
      (
        'Newton',
        'Newton',
        'The SI unit of force',
        'La unidad de fuerza del SI',
      ),
    ],
    explanation: 'Net force tells whether the combined forces change motion.',
    explanationEs:
        'La fuerza neta indica si las fuerzas combinadas cambian el movimiento.',
  ),
  _matching(
    id: 'match-4',
    prompt: 'Match action words to their meanings.',
    promptEs: 'Relaciona las palabras de acción con sus significados.',
    entries: [
      (
        'Push',
        'Empujar',
        'Apply a force away from you',
        'Aplicar una fuerza para alejar algo',
      ),
      (
        'Pull',
        'Tirar',
        'Apply a force toward you',
        'Aplicar una fuerza para acercar algo',
      ),
      (
        'Oppose',
        'Oponerse',
        'Act against something',
        'Actuar en contra de algo',
      ),
      (
        'Balance',
        'Equilibrar',
        'Cancel with an equal opposite force',
        'Cancelar con una fuerza igual y opuesta',
      ),
    ],
    explanation: 'These verbs describe how forces act and interact.',
    explanationEs:
        'Estos verbos describen cómo actúan e interactúan las fuerzas.',
  ),
  _matching(
    id: 'match-5',
    prompt: 'Match each pair of forces to its net force.',
    promptEs: 'Relaciona cada pareja de fuerzas con su fuerza neta.',
    entries: [
      (
        '9 N right and 4 N left',
        '9 N a la derecha y 4 N a la izquierda',
        '5 N right',
        '5 N a la derecha',
      ),
      (
        '8 N left and 3 N right',
        '8 N a la izquierda y 3 N a la derecha',
        '5 N left',
        '5 N a la izquierda',
      ),
      (
        '6 N right and 6 N left',
        '6 N a la derecha y 6 N a la izquierda',
        '0 N',
        '0 N',
      ),
      (
        '3 N right and 7 N right',
        '3 N a la derecha y 7 N a la derecha',
        '10 N right',
        '10 N a la derecha',
      ),
    ],
    explanation:
        'Add forces in the same direction and subtract forces in opposite directions.',
    explanationEs:
        'Suma las fuerzas del mismo sentido y resta las de sentidos opuestos.',
  ),
  _matching(
    id: 'match-6',
    prompt: 'Match everyday examples to their main force.',
    promptEs: 'Relaciona los ejemplos cotidianos con su fuerza principal.',
    entries: [
      (
        'Shoes gripping the floor',
        'Zapatos que se agarran al suelo',
        'Friction',
        'Fricción',
      ),
      ('An apple falling', 'Una manzana que cae', 'Gravity', 'Gravedad'),
      (
        'A hand pushing a door',
        'Una mano que empuja una puerta',
        'Applied force',
        'Fuerza aplicada',
      ),
      (
        'An open parachute slowing a fall',
        'Un paracaídas abierto que frena una caída',
        'Air resistance',
        'Resistencia del aire',
      ),
    ],
    explanation:
        'Look for the interacting objects: surfaces, masses, a hand, or air.',
    explanationEs:
        'Busca qué interactúa: superficies, masas, una mano o el aire.',
  ),
  _matching(
    id: 'match-7',
    prompt: 'Match investigation roles in a test of push strength.',
    promptEs:
        'Relaciona los elementos de una investigación sobre la intensidad de un empujón.',
    entries: [
      (
        'Changed variable',
        'Variable que se cambia',
        'Push strength',
        'Intensidad del empujón',
      ),
      (
        'One controlled variable',
        'Una variable controlada',
        'Cart mass',
        'Masa del carrito',
      ),
      (
        'Measured outcome',
        'Resultado medido',
        'Change in speed',
        'Cambio de velocidad',
      ),
      (
        'Timing tool',
        'Instrumento para medir tiempo',
        'Stopwatch',
        'Cronómetro',
      ),
    ],
    explanation:
        'Change one variable and keep other relevant conditions the same.',
    explanationEs:
        'Cambia una variable y mantén iguales las demás condiciones relevantes.',
  ),
  _matching(
    id: 'match-8',
    prompt: 'Match these force statements to their totals.',
    promptEs: 'Relaciona estas fuerzas con sus resultados totales.',
    entries: [
      (
        '4 N left and 4 N right',
        '4 N a la izquierda y 4 N a la derecha',
        'Zero net force',
        'Fuerza neta cero',
      ),
      (
        '8 N right and 3 N left',
        '8 N a la derecha y 3 N a la izquierda',
        'Net force of 5 N right',
        'Fuerza neta de 5 N a la derecha',
      ),
      (
        '8 N left and 3 N right',
        '8 N a la izquierda y 3 N a la derecha',
        'Net force of 5 N left',
        'Fuerza neta de 5 N a la izquierda',
      ),
      (
        '8 N right and 3 N right',
        '8 N a la derecha y 3 N a la derecha',
        'Net force of 11 N right',
        'Fuerza neta de 11 N a la derecha',
      ),
    ],
    explanation:
        'Direction is part of the answer, not just the number of newtons.',
    explanationEs:
        'La dirección forma parte de la respuesta, no solo el número de newtons.',
  ),
  _matching(
    id: 'match-9',
    prompt: 'Match interaction ideas to the statements they describe.',
    promptEs: 'Relaciona las ideas de interacción con sus descripciones.',
    entries: [
      (
        'Balanced forces',
        'Fuerzas equilibradas',
        'No change in velocity',
        'Sin cambio de velocidad',
      ),
      (
        'Unbalanced forces',
        'Fuerzas desequilibradas',
        'A nonzero acceleration',
        'Una aceleración distinta de cero',
      ),
      (
        'Action and reaction',
        'Acción y reacción',
        'Equal opposite forces on different objects',
        'Fuerzas iguales y opuestas sobre objetos distintos',
      ),
      (
        'Frictional heating',
        'Calentamiento por fricción',
        'Energy transferred to heat',
        'Energía transferida al calor',
      ),
    ],
    explanation:
        'Balanced forces act on one object; an action-reaction pair acts on two different objects.',
    explanationEs:
        'Las fuerzas equilibradas actúan sobre un objeto; acción y reacción actúan sobre dos objetos distintos.',
  ),
  _matching(
    id: 'match-10',
    prompt: 'Match contact and force-description words to their meanings.',
    promptEs:
        'Relaciona las palabras de contacto y descripción de fuerzas con sus significados.',
    entries: [
      (
        'Contact force',
        'Fuerza de contacto',
        'Requires touching',
        'Requiere contacto',
      ),
      (
        'Non-contact force',
        'Fuerza sin contacto',
        'Acts without touching',
        'Actúa sin contacto',
      ),
      (
        'Magnitude',
        'Magnitud',
        'The size of a force',
        'El tamaño de una fuerza',
      ),
      (
        'Direction',
        'Dirección',
        'Which way a force acts',
        'Hacia dónde actúa una fuerza',
      ),
    ],
    explanation: 'A force description needs both a magnitude and a direction.',
    explanationEs:
        'Para describir una fuerza se necesitan magnitud y dirección.',
  ),
];

final gravityPracticeQuestions = <Question>[
  _choice(
    id: 'blank-2',
    kind: QuestionKind.blank,
    prompt: 'The amount of matter in an object is its ___.',
    promptEs: 'La cantidad de materia de un objeto es su ___.',
    choices: [
      ('mass', 'masa'),
      ('weight', 'peso'),
      ('speed', 'velocidad'),
      ('temperature', 'temperatura'),
    ],
    answer: 0,
    explanation:
        'Mass describes the amount of matter, not the gravitational force on it.',
    explanationEs:
        'La masa describe la cantidad de materia, no la fuerza gravitatoria que actúa sobre ella.',
  ),
  _choice(
    id: 'blank-3',
    kind: QuestionKind.blank,
    prompt: 'The gravitational force on an object is its ___.',
    promptEs: 'La fuerza gravitatoria sobre un objeto es su ___.',
    choices: [
      ('weight', 'peso'),
      ('mass', 'masa'),
      ('volume', 'volumen'),
      ('time', 'tiempo'),
    ],
    answer: 0,
    explanation: 'Weight is a force and is measured in newtons.',
    explanationEs: 'El peso es una fuerza y se mide en newtons.',
  ),
  _choice(
    id: 'blank-4',
    kind: QuestionKind.blank,
    prompt: 'Mass is measured in ___.',
    promptEs: 'La masa se mide en ___.',
    choices: [
      ('kilograms', 'kilogramos'),
      ('newtons', 'newtons'),
      ('seconds', 'segundos'),
      ('metres', 'metros'),
    ],
    answer: 0,
    explanation:
        'Kilograms measure mass; newtons measure force, including weight.',
    explanationEs:
        'Los kilogramos miden masa; los newtons miden fuerzas, incluido el peso.',
  ),
  _choice(
    id: 'blank-5',
    kind: QuestionKind.blank,
    prompt: 'At 10 N/kg, the weight of a 4 kg object is ___ N.',
    promptEs: 'Con una gravedad de 10 N/kg, un objeto de 4 kg pesa ___ N.',
    choices: [('40', '40'), ('4', '4'), ('10', '10'), ('400', '400')],
    answer: 0,
    explanation: 'Multiply mass by field strength: 4 times 10 = 40 N.',
    explanationEs:
        'Multiplica la masa por la intensidad del campo: 4 por 10 = 40 N.',
  ),
  _choice(
    id: 'blank-6',
    kind: QuestionKind.blank,
    prompt:
        'Moving the same backpack to the Moon changes its weight, not its ___.',
    promptEs: 'Llevar la misma mochila a la Luna cambia su peso, no su ___.',
    choices: [
      ('mass', 'masa'),
      ('location', 'ubicación'),
      ('surroundings', 'entorno'),
      ('gravitational field', 'campo gravitatorio'),
    ],
    answer: 0,
    explanation:
        'Changing location alone does not change the matter in the backpack.',
    explanationEs:
        'Cambiar solo de lugar no cambia la materia que contiene la mochila.',
  ),
  _choice(
    id: 'blank-7',
    kind: QuestionKind.blank,
    prompt:
        'Without air resistance, objects dropped together from the same height land at the ___ time.',
    promptEs:
        'Sin resistencia del aire, los objetos soltados juntos desde la misma altura llegan al suelo al ___ tiempo.',
    choices: [
      ('same', 'mismo'),
      ('heavier', 'más pesado'),
      ('longest', 'más largo'),
      ('opposite', 'opuesto'),
    ],
    answer: 0,
    explanation:
        'Near Earth, objects in ideal free fall have the same acceleration regardless of mass.',
    explanationEs:
        'Cerca de la Tierra, los objetos en caída libre ideal tienen la misma aceleración sin importar su masa.',
  ),
  _choice(
    id: 'blank-8',
    kind: QuestionKind.blank,
    prompt:
        'Complete the present-tense sentence: Gravity ___ objects toward one another.',
    promptEs:
        'Completa en presente: La gravedad ___ los objetos unos hacia otros.',
    choices: [
      ('pulls', 'atrae'),
      ('pull', 'atraen'),
      ('pulling', 'atrayendo'),
      ('are pulling', 'están atrayendo'),
    ],
    answer: 0,
    explanation:
        'Gravity is singular, so the present-tense verb takes s: gravity pulls.',
    explanationEs:
        'Gravity es singular; en presente se añade s al verbo: gravity pulls.',
  ),
  _choice(
    id: 'blank-9',
    kind: QuestionKind.blank,
    prompt: 'While a thrown ball rises, gravity still pulls ___.',
    promptEs:
        'Mientras una pelota lanzada sube, la gravedad sigue atrayéndola ___.',
    choices: [
      ('downward', 'hacia abajo'),
      ('upward', 'hacia arriba'),
      ('sideways', 'hacia un lado'),
      ('nowhere', 'hacia ningún lado'),
    ],
    answer: 0,
    explanation:
        'Gravity near Earth points toward Earth\'s centre even while a ball rises.',
    explanationEs:
        'La gravedad cerca de la Tierra apunta hacia su centro incluso cuando la pelota sube.',
  ),
  _choice(
    id: 'blank-10',
    kind: QuestionKind.blank,
    prompt:
        'At the same separation, increasing one mass makes gravitational attraction ___.',
    promptEs:
        'A la misma distancia, aumentar una masa hace que la atracción gravitatoria sea ___.',
    choices: [
      ('stronger', 'más fuerte'),
      ('weaker', 'más débil'),
      ('zero', 'nula'),
      ('repulsive', 'repulsiva'),
    ],
    answer: 0,
    explanation:
        'The gravitational interaction grows stronger when a mass increases at fixed separation.',
    explanationEs:
        'La interacción gravitatoria aumenta al crecer una masa sin cambiar la distancia.',
  ),
  _choice(
    id: 'odd-2',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT a mass unit?',
    promptEs: '¿Cuál NO es una unidad de masa?',
    choices: [
      ('kilogram', 'kilogramo'),
      ('gram', 'gramo'),
      ('milligram', 'miligramo'),
      ('newton', 'newton'),
    ],
    answer: 3,
    explanation: 'A newton measures force rather than mass.',
    explanationEs: 'Un newton mide fuerza, no masa.',
  ),
  _choice(
    id: 'odd-3',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT an example of gravitational attraction?',
    promptEs: '¿Cuál NO es un ejemplo de atracción gravitatoria?',
    choices: [
      ('an apple falling', 'una manzana que cae'),
      ('the Moon orbiting Earth', 'la Luna orbitando la Tierra'),
      ('Earth orbiting the Sun', 'la Tierra orbitando el Sol'),
      (
        'like magnetic poles repelling',
        'polos magnéticos iguales que se repelen',
      ),
    ],
    answer: 3,
    explanation:
        'Magnetic repulsion is a different interaction; gravity between masses is attractive.',
    explanationEs:
        'La repulsión magnética es otra interacción; la gravedad entre masas es atractiva.',
  ),
  _choice(
    id: 'odd-4',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which phrase does NOT describe weight?',
    promptEs: '¿Qué frase NO describe el peso?',
    choices: [
      ('a force', 'una fuerza'),
      ('measured in newtons', 'se mide en newtons'),
      ('depends on gravity', 'depende de la gravedad'),
      ('the amount of matter', 'la cantidad de materia'),
    ],
    answer: 3,
    explanation: 'The amount of matter describes mass, not weight.',
    explanationEs: 'La cantidad de materia describe la masa, no el peso.',
  ),
  _choice(
    id: 'odd-5',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which statement does NOT describe ideal free fall?',
    promptEs: '¿Qué afirmación NO describe la caída libre ideal?',
    choices: [
      ('only gravity acts', 'solo actúa la gravedad'),
      (
        'air resistance can be neglected',
        'se puede despreciar la resistencia del aire',
      ),
      ('speed can change', 'la velocidad puede cambiar'),
      ('air drag balances weight', 'la resistencia del aire equilibra el peso'),
    ],
    answer: 3,
    explanation:
        'If air drag balances weight, another force is acting, so the motion is not ideal free fall.',
    explanationEs:
        'Si el aire equilibra el peso, actúa otra fuerza y no es una caída libre ideal.',
  ),
  _choice(
    id: 'odd-6',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which action does NOT leave an object\'s mass unchanged?',
    promptEs: '¿Qué acción NO deja igual la masa de un objeto?',
    choices: [
      ('moving it to the Moon', 'llevarlo a la Luna'),
      ('moving it to Mars', 'llevarlo a Marte'),
      ('moving it across a classroom', 'moverlo por el salón'),
      ('removing half its contents', 'quitar la mitad de su contenido'),
    ],
    answer: 3,
    explanation:
        'Removing contents removes matter and changes mass; moving location alone does not.',
    explanationEs:
        'Quitar contenido elimina materia y cambia la masa; cambiar solo de lugar no lo hace.',
  ),
  _choice(
    id: 'odd-7',
    kind: QuestionKind.oddOneOut,
    prompt: 'Using 10 N/kg, which mass-weight pair is NOT correct?',
    promptEs: 'Usando 10 N/kg, ¿qué pareja de masa y peso NO es correcta?',
    choices: [
      ('1 kg and 10 N', '1 kg y 10 N'),
      ('2 kg and 20 N', '2 kg y 20 N'),
      ('3 kg and 30 N', '3 kg y 30 N'),
      ('4 kg and 4 N', '4 kg y 4 N'),
    ],
    answer: 3,
    explanation: 'At 10 N/kg, an object of 4 kg weighs 40 N, not 4 N.',
    explanationEs: 'Con 10 N/kg, un objeto de 4 kg pesa 40 N, no 4 N.',
  ),
  _choice(
    id: 'odd-8',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which phrase does NOT mean attraction?',
    promptEs: '¿Qué frase NO significa atracción?',
    choices: [
      ('pulling together', 'atraer para juntar'),
      ('pulling toward', 'atraer hacia'),
      ('pulling inward', 'atraer hacia dentro'),
      ('pushing apart', 'empujar para separar'),
    ],
    answer: 3,
    explanation:
        'Pushing apart describes repulsion, the opposite of attraction.',
    explanationEs:
        'Empujar para separar describe repulsión, lo contrario de atracción.',
  ),
  _choice(
    id: 'odd-9',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT a tool for measuring mass or weight?',
    promptEs: '¿Cuál NO es un instrumento para medir masa o peso?',
    choices: [
      ('a balance', 'una balanza'),
      ('a spring scale', 'un dinamómetro'),
      ('a calibrated digital mass scale', 'una báscula digital calibrada'),
      ('a stopwatch', 'un cronómetro'),
    ],
    answer: 3,
    explanation: 'A stopwatch measures elapsed time.',
    explanationEs: 'Un cronómetro mide el tiempo transcurrido.',
  ),
  _choice(
    id: 'odd-10',
    kind: QuestionKind.oddOneOut,
    prompt:
        'Without air, which statement about objects dropped together from the same height is NOT correct?',
    promptEs:
        'Sin aire, ¿qué afirmación sobre objetos soltados juntos desde la misma altura NO es correcta?',
    choices: [
      ('gravity acts on them', 'la gravedad actúa sobre ellos'),
      (
        'heavy and light objects land together',
        'los objetos pesados y ligeros llegan juntos',
      ),
      (
        'their free-fall acceleration is the same',
        'tienen la misma aceleración de caída libre',
      ),
      (
        'the heavier object always lands first',
        'el objeto más pesado siempre llega primero',
      ),
    ],
    answer: 3,
    explanation:
        'In ideal free fall at the same place, mass does not make one object accelerate faster.',
    explanationEs:
        'En caída libre ideal en el mismo lugar, una masa mayor no produce más aceleración.',
  ),
  _matching(
    id: 'match-2',
    prompt: 'Match gravity measurements to their units.',
    promptEs: 'Relaciona las mediciones de gravedad con sus unidades.',
    entries: [
      ('Mass', 'Masa', 'Kilograms', 'Kilogramos'),
      ('Weight', 'Peso', 'Newtons', 'Newtons'),
      (
        'Gravitational field strength',
        'Intensidad del campo gravitatorio',
        'Newtons per kilogram',
        'Newtons por kilogramo',
      ),
      ('Time', 'Tiempo', 'Seconds', 'Segundos'),
    ],
    explanation:
        'Mass and weight have different units because weight is a force.',
    explanationEs:
        'Masa y peso tienen unidades distintas porque el peso es una fuerza.',
  ),
  _matching(
    id: 'match-3',
    prompt: 'Match gravity vocabulary to clear definitions.',
    promptEs: 'Relaciona el vocabulario de gravedad con definiciones claras.',
    entries: [
      (
        'Gravitational attraction',
        'Atracción gravitatoria',
        'Masses pulling toward one another',
        'Masas que se atraen entre sí',
      ),
      (
        'Air resistance',
        'Resistencia del aire',
        'Air opposing motion',
        'Aire que se opone al movimiento',
      ),
      ('Mass', 'Masa', 'Amount of matter', 'Cantidad de materia'),
      (
        'Weight',
        'Peso',
        'Gravitational force on a mass',
        'Fuerza gravitatoria sobre una masa',
      ),
    ],
    explanation:
        'Do not confuse an amount of matter with a force acting on that matter.',
    explanationEs:
        'No confundas una cantidad de materia con una fuerza que actúa sobre ella.',
  ),
  _matching(
    id: 'match-4',
    prompt: 'Match Earth-and-Moon statements to the correct facts.',
    promptEs:
        'Relaciona las afirmaciones sobre la Tierra y la Luna con los hechos correctos.',
    entries: [
      (
        'An unchanged object\'s mass on the Moon',
        'La masa de un objeto sin modificar en la Luna',
        'The same as on Earth',
        'La misma que en la Tierra',
      ),
      (
        'An unchanged object\'s weight on the Moon',
        'El peso de un objeto sin modificar en la Luna',
        'Less than on Earth',
        'Menor que en la Tierra',
      ),
      (
        'Gravity\'s direction near Earth',
        'La dirección de la gravedad cerca de la Tierra',
        'Toward Earth\'s centre',
        'Hacia el centro de la Tierra',
      ),
      (
        'Earth\'s gravity above the atmosphere',
        'La gravedad terrestre sobre la atmósfera',
        'Still acts',
        'Sigue actuando',
      ),
    ],
    explanation:
        'Location can change weight without changing an object\'s matter.',
    explanationEs:
        'El lugar puede cambiar el peso sin cambiar la materia del objeto.',
  ),
  _matching(
    id: 'match-5',
    prompt: 'Using 10 N/kg, match each mass to its weight.',
    promptEs: 'Usando 10 N/kg, relaciona cada masa con su peso.',
    entries: [
      ('2 kg', '2 kg', '20 N', '20 N'),
      ('3 kg', '3 kg', '30 N', '30 N'),
      ('4 kg', '4 kg', '40 N', '40 N'),
      ('5 kg', '5 kg', '50 N', '50 N'),
    ],
    explanation: 'Multiply every mass by 10 newtons per kilogram.',
    explanationEs: 'Multiplica cada masa por 10 newtons por kilogramo.',
  ),
  _matching(
    id: 'match-6',
    prompt:
        'Match a 4 kg object in each stated gravitational field to its weight.',
    promptEs:
        'Relaciona un objeto de 4 kg en cada campo gravitatorio indicado con su peso.',
    entries: [
      ('4 kg at 2 N/kg', '4 kg con 2 N/kg', '8 N', '8 N'),
      ('4 kg at 4 N/kg', '4 kg con 4 N/kg', '16 N', '16 N'),
      ('4 kg at 6 N/kg', '4 kg con 6 N/kg', '24 N', '24 N'),
      ('4 kg at 8 N/kg', '4 kg con 8 N/kg', '32 N', '32 N'),
    ],
    explanation:
        'The mass stays 4 kg; multiply it by each different field strength.',
    explanationEs:
        'La masa sigue siendo de 4 kg; multiplícala por cada intensidad de campo.',
  ),
  _matching(
    id: 'match-7',
    prompt: 'Match falling-motion terms to their meanings.',
    promptEs: 'Relaciona los términos de caída con sus significados.',
    entries: [
      ('Vacuum', 'Vacío', 'A space with no air', 'Un espacio sin aire'),
      (
        'Free fall',
        'Caída libre',
        'Motion under gravity alone',
        'Movimiento bajo la acción exclusiva de la gravedad',
      ),
      (
        'Air resistance',
        'Resistencia del aire',
        'A force from air against motion',
        'Una fuerza del aire contraria al movimiento',
      ),
      (
        'Terminal speed',
        'Velocidad terminal',
        'Constant falling speed when drag balances weight',
        'Velocidad de caída constante cuando el aire equilibra el peso',
      ),
    ],
    explanation:
        'Free fall has no significant air drag; terminal speed involves balanced weight and drag.',
    explanationEs:
        'La caída libre no tiene resistencia del aire significativa; en la velocidad terminal el peso y la resistencia se equilibran.',
  ),
  _matching(
    id: 'match-8',
    prompt: 'Match direction and gravity words to their meanings.',
    promptEs:
        'Relaciona las palabras de dirección y gravedad con sus significados.',
    entries: [
      (
        'Upward',
        'Hacia arriba',
        'Away from Earth\'s centre',
        'Alejándose del centro de la Tierra',
      ),
      (
        'Downward',
        'Hacia abajo',
        'Toward Earth\'s centre',
        'Hacia el centro de la Tierra',
      ),
      (
        'Orbit',
        'Órbita',
        'A curved path around a body',
        'Una trayectoria curva alrededor de un cuerpo',
      ),
      (
        'Attraction',
        'Atracción',
        'A pull toward another object',
        'Un tirón hacia otro objeto',
      ),
    ],
    explanation:
        'These words help describe direction and motion without relying on a picture.',
    explanationEs:
        'Estas palabras permiten describir dirección y movimiento sin depender de un dibujo.',
  ),
  _matching(
    id: 'match-9',
    prompt: 'Match measurement tools to their main purpose.',
    promptEs:
        'Relaciona los instrumentos de medición con su función principal.',
    entries: [
      ('Balance', 'Balanza', 'Compares masses', 'Compara masas'),
      ('Spring scale', 'Dinamómetro', 'Measures force', 'Mide fuerza'),
      ('Metre stick', 'Metro de medir', 'Measures length', 'Mide longitud'),
      ('Stopwatch', 'Cronómetro', 'Measures time', 'Mide tiempo'),
    ],
    explanation:
        'Select the instrument for the physical quantity you want to measure.',
    explanationEs:
        'Selecciona el instrumento apropiado para la magnitud que quieres medir.',
  ),
  _matching(
    id: 'match-10',
    prompt: 'Match Earth, Moon, mass, and weight to their descriptions.',
    promptEs: 'Relaciona Tierra, Luna, masa y peso con sus descripciones.',
    entries: [
      ('Earth', 'Tierra', 'Our home planet', 'Nuestro planeta'),
      (
        'Moon',
        'Luna',
        'Earth\'s natural satellite',
        'El satélite natural de la Tierra',
      ),
      (
        'Mass',
        'Masa',
        'Matter contained in an object',
        'Materia que contiene un objeto',
      ),
      (
        'Weight',
        'Peso',
        'Gravity\'s pull on an object',
        'Atracción gravitatoria sobre un objeto',
      ),
    ],
    explanation:
        'Earth and the Moon are bodies; mass and weight are quantities used to describe objects.',
    explanationEs:
        'La Tierra y la Luna son cuerpos; masa y peso son magnitudes para describir objetos.',
  ),
];

final machinesPracticeQuestions = <Question>[
  _choice(
    id: 'blank-2',
    kind: QuestionKind.blank,
    prompt: 'A lever turns around a fixed point called the ___.',
    promptEs: 'Una palanca gira alrededor de un punto fijo llamado ___.',
    choices: [
      ('fulcrum', 'fulcro'),
      ('load', 'carga'),
      ('effort', 'esfuerzo'),
      ('rope', 'cuerda'),
    ],
    answer: 0,
    explanation: 'The fulcrum is the lever\'s pivot point.',
    explanationEs: 'El fulcro es el punto de apoyo de la palanca.',
  ),
  _choice(
    id: 'blank-3',
    kind: QuestionKind.blank,
    prompt: 'The input force applied to a machine is the ___.',
    promptEs: 'La fuerza de entrada aplicada a una máquina es el ___.',
    choices: [
      ('effort', 'esfuerzo'),
      ('load', 'valor de la carga'),
      ('fulcrum', 'fulcro'),
      ('temperature', 'cambio de temperatura'),
    ],
    answer: 0,
    explanation:
        'Effort names the force supplied by the user or another machine.',
    explanationEs:
        'El esfuerzo es la fuerza que aporta una persona u otra máquina.',
  ),
  _choice(
    id: 'blank-4',
    kind: QuestionKind.blank,
    prompt: 'For the same height, a longer ideal ramp requires ___ force.',
    promptEs:
        'Para la misma altura, una rampa ideal más larga requiere ___ fuerza.',
    choices: [
      ('less', 'menos'),
      ('more', 'más'),
      ('zero', 'cero'),
      ('infinite', 'infinita'),
    ],
    answer: 0,
    explanation:
        'A longer ramp trades a longer input distance for a smaller force.',
    explanationEs:
        'Una rampa más larga cambia una mayor distancia de entrada por una fuerza menor.',
  ),
  _choice(
    id: 'blank-5',
    kind: QuestionKind.blank,
    prompt: 'A single fixed pulley changes the ___ of a pull.',
    promptEs: 'Una polea fija cambia la ___ de un tirón.',
    choices: [
      ('direction', 'dirección'),
      ('mass', 'masa'),
      ('gravity', 'gravedad'),
      ('created energy', 'energía creada'),
    ],
    answer: 0,
    explanation:
        'An ideal single fixed pulley redirects the pull without reducing its size.',
    explanationEs:
        'Una polea fija ideal cambia el sentido del tirón sin reducir su magnitud.',
  ),
  _choice(
    id: 'blank-6',
    kind: QuestionKind.blank,
    prompt:
        'Four vertical strands support 200 N at steady speed in an ideal pulley system. The pull is ___ N.',
    promptEs:
        'Cuatro ramales verticales sostienen 200 N a velocidad constante en un sistema ideal. El tirón es de ___ N.',
    choices: [('50', '50'), ('200', '200'), ('800', '800'), ('4', '4')],
    answer: 0,
    explanation: 'The four strands share the load: 200 divided by 4 = 50 N.',
    explanationEs:
        'Los cuatro ramales comparten la carga: 200 dividido entre 4 = 50 N.',
  ),
  _choice(
    id: 'blank-7',
    kind: QuestionKind.blank,
    prompt: 'A simple machine cannot create extra ___.',
    promptEs: 'Una máquina simple no puede crear ___ adicional.',
    choices: [
      ('energy', 'energía'),
      ('force', 'fuerza'),
      ('distance', 'distancia'),
      ('speed', 'velocidad'),
    ],
    answer: 0,
    explanation: 'Machines transfer energy; they do not create extra energy.',
    explanationEs:
        'Las máquinas transfieren energía; no crean energía adicional.',
  ),
  _choice(
    id: 'blank-8',
    kind: QuestionKind.blank,
    prompt:
        'Complete the English sentence: The ramp ___ longer than the ladder.',
    promptEs: 'Completa la oración: La rampa ___ más larga que la escalera.',
    choices: [('is', 'es'), ('are', 'son'), ('am', 'soy'), ('be', 'ser')],
    answer: 0,
    explanation:
        'The ramp is singular, so use is. Longer than is a comparison.',
    explanationEs:
        'The ramp es singular y usa is. Longer than expresa una comparación.',
  ),
  _choice(
    id: 'blank-9',
    kind: QuestionKind.blank,
    prompt:
        'For a constant force, work is force multiplied by ___ moved in the force\'s direction.',
    promptEs:
        'Con una fuerza constante, el trabajo es la fuerza multiplicada por la ___ recorrida en su dirección.',
    choices: [
      ('distance', 'distancia'),
      ('mass', 'masa'),
      ('temperature', 'temperatura'),
      ('colour', 'tonalidad'),
    ],
    answer: 0,
    explanation:
        'Work depends on force and displacement along that force, not mass or colour alone.',
    explanationEs:
        'El trabajo depende de la fuerza y del desplazamiento en su dirección, no solo de la masa o el color.',
  ),
  _choice(
    id: 'blank-10',
    kind: QuestionKind.blank,
    prompt:
        'Keeping a lever\'s fulcrum and load fixed, less effort is needed when you push ___ from the fulcrum.',
    promptEs:
        'Con el fulcro y la carga fijos, se necesita menos esfuerzo al empujar ___ del fulcro.',
    choices: [
      ('farther', 'más lejos'),
      ('closer', 'más cerca'),
      ('directly', 'directamente'),
      ('nowhere', 'en ningún lugar'),
    ],
    answer: 0,
    explanation:
        'A longer effort arm increases the lever\'s mechanical advantage.',
    explanationEs:
        'Un brazo del esfuerzo más largo aumenta la ventaja mecánica de la palanca.',
  ),
  _choice(
    id: 'odd-2',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT one of the basic simple-machine types?',
    promptEs: '¿Cuál NO es un tipo básico de máquina simple?',
    choices: [
      ('wheel and axle', 'rueda y eje'),
      ('screw', 'tornillo'),
      ('wedge', 'cuña'),
      ('electric motor', 'motor eléctrico'),
    ],
    answer: 3,
    explanation:
        'A motor converts electrical energy into motion; a wheel and axle, screw, and wedge are simple-machine types.',
    explanationEs:
        'Un motor convierte energía eléctrica en movimiento; rueda y eje, tornillo y cuña son máquinas simples.',
  ),
  _choice(
    id: 'odd-3',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT a lever part or input/output term?',
    promptEs:
        '¿Cuál NO es una parte o término de entrada y salida de una palanca?',
    choices: [
      ('fulcrum', 'fulcro'),
      ('effort', 'esfuerzo'),
      ('load', 'carga'),
      ('temperature', 'temperatura'),
    ],
    answer: 3,
    explanation: 'Temperature is not the lever\'s pivot, input force, or load.',
    explanationEs:
        'La temperatura no es el punto de apoyo, la fuerza de entrada ni la carga.',
  ),
  _choice(
    id: 'odd-4',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which phrase does NOT describe a ramp?',
    promptEs: '¿Qué frase NO describe una rampa?',
    choices: [
      ('inclined plane', 'plano inclinado'),
      ('sloping surface', 'superficie inclinada'),
      ('sloped path', 'camino inclinado'),
      ('spinning wheel', 'rueda que gira'),
    ],
    answer: 3,
    explanation: 'A ramp is an inclined surface, not a rotating wheel.',
    explanationEs:
        'Una rampa es una superficie inclinada, no una rueda que gira.',
  ),
  _choice(
    id: 'odd-5',
    kind: QuestionKind.oddOneOut,
    prompt:
        'For the same load, which change does NOT reduce effort in an ideal lever?',
    promptEs:
        'Para la misma carga, ¿qué cambio NO reduce el esfuerzo en una palanca ideal?',
    choices: [
      ('lengthening the effort arm', 'alargar el brazo del esfuerzo'),
      ('pushing farther from the fulcrum', 'empujar más lejos del fulcro'),
      ('moving the fulcrum closer to the load', 'acercar el fulcro a la carga'),
      ('shortening the effort arm', 'acortar el brazo del esfuerzo'),
    ],
    answer: 3,
    explanation:
        'A shorter effort arm needs more input force for the same load arm.',
    explanationEs:
        'Un brazo del esfuerzo más corto necesita más fuerza para el mismo brazo de la carga.',
  ),
  _choice(
    id: 'odd-6',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which statement is NOT true of an ideal single fixed pulley?',
    promptEs: '¿Qué afirmación NO es cierta para una polea fija ideal?',
    choices: [
      ('it changes pull direction', 'cambia la dirección del tirón'),
      ('its mechanical advantage is one', 'su ventaja mecánica es uno'),
      ('it does not create energy', 'no crea energía'),
      (
        'it cuts the required pull in half',
        'reduce el tirón necesario a la mitad',
      ),
    ],
    answer: 3,
    explanation:
        'A fixed pulley redirects force; reducing force requires a different pulley arrangement.',
    explanationEs:
        'Una polea fija redirige la fuerza; para reducirla se necesita otra disposición de poleas.',
  ),
  _choice(
    id: 'odd-7',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT a force measurement?',
    promptEs: '¿Cuál NO es una medición de fuerza?',
    choices: [
      ('10 N', '10 N'),
      ('20 newtons', '20 newtons'),
      ('30 N', '30 N'),
      ('2 metres', '2 metros'),
    ],
    answer: 3,
    explanation: 'Metres measure distance, not force.',
    explanationEs: 'Los metros miden distancia, no fuerza.',
  ),
  _choice(
    id: 'odd-8',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which statement does NOT describe an ideal friction-free machine?',
    promptEs: '¿Qué afirmación NO describe una máquina ideal sin fricción?',
    choices: [
      ('no frictional energy loss', 'no pierde energía por fricción'),
      ('no extra energy is created', 'no crea energía adicional'),
      (
        'input work equals useful output work',
        'el trabajo de entrada iguala al trabajo útil',
      ),
      (
        'energy is always lost to frictional heating',
        'siempre pierde energía por calentamiento por fricción',
      ),
    ],
    answer: 3,
    explanation:
        'The ideal model neglects friction; real machines may transfer some energy to heat.',
    explanationEs:
        'El modelo ideal desprecia la fricción; las máquinas reales pueden transferir energía al calor.',
  ),
  _choice(
    id: 'odd-9',
    kind: QuestionKind.oddOneOut,
    prompt: 'Which is NOT a design constraint for a loading ramp?',
    promptEs: '¿Cuál NO es una limitación de diseño de una rampa de carga?',
    choices: [
      ('maximum ramp length', 'longitud máxima de la rampa'),
      ('available space', 'espacio disponible'),
      ('allowed materials', 'materiales permitidos'),
      (
        'the colour of a spectator\'s shirt',
        'el color de la camisa de un espectador',
      ),
    ],
    answer: 3,
    explanation:
        'A design constraint limits the solution; a spectator\'s shirt does not limit the ramp.',
    explanationEs:
        'Una limitación restringe la solución; la camisa de un espectador no restringe la rampa.',
  ),
  _choice(
    id: 'odd-10',
    kind: QuestionKind.oddOneOut,
    prompt:
        'For ideal pulleys lifting at steady speed, which load, vertical strand count, and pull is NOT correct?',
    promptEs:
        'En poleas ideales que elevan a velocidad constante, ¿qué combinación de carga, ramales verticales y tirón NO es correcta?',
    choices: [
      ('100 N, 2 strands, 50 N pull', '100 N, 2 ramales, tirón de 50 N'),
      ('120 N, 3 strands, 40 N pull', '120 N, 3 ramales, tirón de 40 N'),
      ('200 N, 4 strands, 50 N pull', '200 N, 4 ramales, tirón de 50 N'),
      ('100 N, 4 strands, 100 N pull', '100 N, 4 ramales, tirón de 100 N'),
    ],
    answer: 3,
    explanation:
        'A 100 N load on four supporting strands needs an ideal pull of 25 N, not 100 N.',
    explanationEs:
        'Una carga de 100 N sostenida por cuatro ramales necesita idealmente 25 N, no 100 N.',
  ),
  _matching(
    id: 'match-2',
    prompt: 'Match simple machines to their definitions.',
    promptEs: 'Relaciona las máquinas simples con sus definiciones.',
    entries: [
      (
        'Lever',
        'Palanca',
        'A rigid bar turning around a pivot',
        'Una barra rígida que gira sobre un apoyo',
      ),
      ('Ramp', 'Rampa', 'A sloping surface', 'Una superficie inclinada'),
      (
        'Pulley',
        'Polea',
        'A wheel guiding a rope',
        'Una rueda que guía una cuerda',
      ),
      (
        'Simple machine',
        'Máquina simple',
        'A device changing the size or direction of a force',
        'Un dispositivo que cambia magnitud o dirección de una fuerza',
      ),
    ],
    explanation: 'The shape and motion of a machine help identify its type.',
    explanationEs:
        'La forma y el movimiento de una máquina ayudan a identificar su tipo.',
  ),
  _matching(
    id: 'match-3',
    prompt: 'Match machine vocabulary to its meaning.',
    promptEs: 'Relaciona el vocabulario de máquinas con sus significados.',
    entries: [
      ('Effort', 'Esfuerzo', 'The input force', 'La fuerza de entrada'),
      (
        'Load',
        'Carga',
        'What the machine must move',
        'Lo que la máquina debe mover',
      ),
      (
        'Fulcrum',
        'Fulcro',
        'The pivot point of a lever',
        'El punto de apoyo de una palanca',
      ),
      (
        'Mechanical advantage',
        'Ventaja mecánica',
        'Output force divided by input force',
        'Fuerza de salida dividida entre fuerza de entrada',
      ),
    ],
    explanation:
        'Effort is supplied to the machine; the load receives the output force.',
    explanationEs:
        'El esfuerzo se aplica a la máquina; la carga recibe la fuerza de salida.',
  ),
  _matching(
    id: 'match-4',
    prompt: 'Match everyday examples to simple-machine types.',
    promptEs:
        'Relaciona los ejemplos cotidianos con los tipos de máquinas simples.',
    entries: [
      ('Seesaw', 'Balancín', 'Lever', 'Palanca'),
      ('Doorstop', 'Tope de puerta en forma de cuña', 'Wedge', 'Cuña'),
      (
        'Round door knob and its shaft',
        'Manija redonda y su eje',
        'Wheel and axle',
        'Rueda y eje',
      ),
      ('Thread on a jar lid', 'Rosca de una tapa', 'Screw', 'Tornillo'),
    ],
    explanation:
        'Several everyday objects use one of the basic simple-machine patterns.',
    explanationEs:
        'Muchos objetos cotidianos usan uno de los tipos básicos de máquinas simples.',
  ),
  _matching(
    id: 'match-5',
    prompt: 'Match physical quantities used with machines to their SI units.',
    promptEs:
        'Relaciona las magnitudes usadas con máquinas con sus unidades del SI.',
    entries: [
      ('Force', 'Fuerza', 'Newtons', 'Newtons'),
      ('Distance', 'Distancia', 'Metres', 'Metros'),
      ('Work', 'Trabajo', 'Joules', 'Julios'),
      ('Mass', 'Masa', 'Kilograms', 'Kilogramos'),
    ],
    explanation: 'A calculation must use the correct unit for each quantity.',
    explanationEs:
        'Un cálculo debe usar la unidad correcta para cada magnitud.',
  ),
  _matching(
    id: 'match-6',
    prompt:
        'For ideal pulleys at steady speed, match the load and vertical strand count to the required pull.',
    promptEs:
        'En poleas ideales a velocidad constante, relaciona carga y ramales verticales con el tirón necesario.',
    entries: [
      (
        '100 N with 2 supporting strands',
        '100 N con 2 ramales de apoyo',
        '50 N pull',
        'Tirón de 50 N',
      ),
      (
        '120 N with 3 supporting strands',
        '120 N con 3 ramales de apoyo',
        '40 N pull',
        'Tirón de 40 N',
      ),
      (
        '120 N with 4 supporting strands',
        '120 N con 4 ramales de apoyo',
        '30 N pull',
        'Tirón de 30 N',
      ),
      (
        '100 N with 4 supporting strands',
        '100 N con 4 ramales de apoyo',
        '25 N pull',
        'Tirón de 25 N',
      ),
    ],
    explanation:
        'Divide the load by the number of vertical supporting strands in this ideal model.',
    explanationEs:
        'En este modelo ideal, divide la carga entre el número de ramales verticales de apoyo.',
  ),
  _matching(
    id: 'match-7',
    prompt:
        'For an ideal pulley, match supporting strands and lift distance to the rope distance pulled.',
    promptEs:
        'En una polea ideal, relaciona ramales y altura de elevación con la longitud de cuerda que debes tirar.',
    entries: [
      (
        '2 strands, 1 metre lift',
        '2 ramales, elevación de 1 metro',
        '2 metres of rope',
        '2 metros de cuerda',
      ),
      (
        '3 strands, 1 metre lift',
        '3 ramales, elevación de 1 metro',
        '3 metres of rope',
        '3 metros de cuerda',
      ),
      (
        '4 strands, 1 metre lift',
        '4 ramales, elevación de 1 metro',
        '4 metres of rope',
        '4 metros de cuerda',
      ),
      (
        '2 strands, 3 metre lift',
        '2 ramales, elevación de 3 metros',
        '6 metres of rope',
        '6 metros de cuerda',
      ),
    ],
    explanation:
        'The rope distance equals the number of supporting strands times the load\'s rise.',
    explanationEs:
        'La distancia de cuerda es el número de ramales de apoyo multiplicado por la altura que sube la carga.',
  ),
  _matching(
    id: 'match-8',
    prompt: 'Match lever-geometry words to their meanings.',
    promptEs:
        'Relaciona las palabras de geometría de palancas con sus significados.',
    entries: [
      (
        'Effort arm',
        'Brazo del esfuerzo',
        'Distance from fulcrum to the input force',
        'Distancia del fulcro a la fuerza de entrada',
      ),
      (
        'Load arm',
        'Brazo de la carga',
        'Distance from fulcrum to the load force',
        'Distancia del fulcro a la fuerza de la carga',
      ),
      (
        'Pivot',
        'Punto de apoyo',
        'The turning point',
        'El punto alrededor del cual se gira',
      ),
      (
        'Lever bar',
        'Barra de la palanca',
        'The rigid part that turns',
        'La parte rígida que gira',
      ),
    ],
    explanation: 'Lever arms are distances measured from the fulcrum.',
    explanationEs:
        'Los brazos de una palanca son distancias medidas desde el fulcro.',
  ),
  _matching(
    id: 'match-9',
    prompt: 'Match machine-energy terms to their descriptions.',
    promptEs:
        'Relaciona los términos de energía de las máquinas con sus descripciones.',
    entries: [
      (
        'Input work',
        'Trabajo de entrada',
        'Work done on the machine',
        'Trabajo realizado sobre la máquina',
      ),
      (
        'Useful output work',
        'Trabajo útil de salida',
        'Work delivered to the load',
        'Trabajo entregado a la carga',
      ),
      (
        'Frictional heating',
        'Calentamiento por fricción',
        'Energy transferred to thermal energy',
        'Energía transferida a energía térmica',
      ),
      (
        'Energy conservation',
        'Conservación de la energía',
        'Energy is transferred, not created',
        'La energía se transfiere, no se crea',
      ),
    ],
    explanation:
        'A real machine may transfer some input energy to heat rather than useful output.',
    explanationEs:
        'Una máquina real puede transferir parte de la energía al calor en vez de al trabajo útil.',
  ),
  _matching(
    id: 'match-10',
    prompt: 'Match design-action phrases to their instructions.',
    promptEs: 'Relaciona las acciones de diseño con sus instrucciones.',
    entries: [
      (
        'Identify the load',
        'Identificar la carga',
        'Find what must be moved',
        'Encuentra lo que debe moverse',
      ),
      (
        'Locate the fulcrum',
        'Localizar el fulcro',
        'Find the pivot point',
        'Encuentra el punto de apoyo',
      ),
      (
        'Apply effort',
        'Aplicar esfuerzo',
        'Push or pull the machine',
        'Empuja o tira de la máquina',
      ),
      (
        'Check constraints',
        'Revisar las limitaciones',
        'Compare the design with its limits',
        'Compara el diseño con sus límites',
      ),
    ],
    explanation:
        'These imperative phrases describe steps in an engineering task.',
    explanationEs:
        'Estas frases imperativas describen pasos de una tarea de ingeniería.',
  ),
];
