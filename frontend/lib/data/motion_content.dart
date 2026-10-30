import '../models/lesson.dart';
import 'practice_exercises.dart';

/// The Motion and Speed lesson. Mirrors backend/seed/lessons/motion.json.
final motionLesson = Lesson(
  id: 'motion',
  title: 'Motion & Speed',
  subtitle: 'How we describe things that move.',
  grade: 6,
  estimatedMinutes: 7,
  sections: [
    LessonSection(
      index: 1,
      title: 'What is motion?',
      titleEs: '¿Qué es el movimiento?',
      art: 'reference',
      demo: 'none',
      body:
          'Something is in motion when its position changes '
          'compared to something else.\n\n'
          'That "something else" is called a reference point. Sitting '
          'on a moving bus you are still compared to your seat, but '
          'moving fast compared to a tree outside. Both answers are '
          'correct — they just use different reference points.',
      bodyEs:
          'Algo está en movimiento cuando su posición cambia en '
          'comparación con otra cosa. Esa otra cosa se llama punto de '
          'referencia. Sentado en un autobús en marcha, estás quieto '
          'respecto a tu asiento, pero te mueves rápido respecto a un '
          'árbol de afuera. Las dos respuestas son correctas: solo usan '
          'puntos de referencia distintos.',
    ),
    LessonSection(
      index: 2,
      title: 'Speed = distance ÷ time',
      titleEs: 'Velocidad = distancia ÷ tiempo',
      art: 'speedometer',
      demo: 'speedFormula',
      body:
          'Speed tells you how much distance is covered in each '
          'unit of time.\n\n'
          'Divide the distance travelled by the time it took. Go 100 '
          'metres in 20 seconds and your speed is 5 metres per second. '
          'Cover more ground in the same time, or the same ground in '
          'less time, and the speed goes up.',
      bodyEs:
          'La velocidad te dice cuánta distancia se recorre en cada '
          'unidad de tiempo. Divide la distancia recorrida entre el '
          'tiempo que tardó. Si recorres cien metros en veinte segundos, '
          'tu velocidad es de cinco metros por segundo. Si cubres más '
          'distancia en el mismo tiempo, o la misma distancia en menos '
          'tiempo, la velocidad aumenta.',
    ),
    LessonSection(
      index: 3,
      title: 'Who is faster?',
      titleEs: '¿Quién es más rápido?',
      art: 'raceTrack',
      demo: 'raceTrack',
      body:
          'To compare two moving things fairly you have to compare '
          'their speeds, not just the distance.\n\n'
          'Finishing first only means you were faster if you both '
          'started together and ran the same track. Otherwise, work '
          'out each speed and compare those.',
      bodyEs:
          'Para comparar dos cosas en movimiento de forma justa hay '
          'que comparar sus velocidades, no solo la distancia. Llegar '
          'primero solo significa que fuiste más rápido si ambos '
          'salieron juntos y recorrieron la misma pista. Si no, calcula '
          'cada velocidad y compáralas.',
    ),
    LessonSection(
      index: 4,
      title: 'Speeding up and slowing down',
      titleEs: 'Acelerar y reducir la velocidad',
      art: 'acceleration',
      demo: 'speedChange',
      body:
          'Speed does not have to stay the same. When it changes, we '
          'say the object is accelerating.\n\n'
          'Speeding up is acceleration. Slowing down is acceleration '
          'too — just in the opposite direction. A steady speed means '
          'no acceleration at all.',
      bodyEs:
          'La velocidad no tiene que quedarse igual. Cuando cambia, '
          'decimos que el objeto acelera. Ir más rápido es aceleración. '
          'Frenar también es aceleración, solo que en dirección '
          'contraria. Una velocidad constante significa que no hay '
          'aceleración.',
    ),
  ],
  keyPoints: [
    'Motion is a change of position.',
    'Motion is always measured against a reference point.',
    'Speed = distance divided by time.',
    'Same distance in less time means more speed.',
    'A change of speed is called acceleration.',
  ],
  keyPointsEs: [
    'El movimiento es un cambio de posición.',
    'El movimiento siempre se mide con respecto a un punto de referencia.',
    'Velocidad = distancia dividida entre tiempo.',
    'La misma distancia en menos tiempo significa mayor velocidad.',
    'Un cambio de velocidad se llama aceleración.',
  ],
  glossary: [
    GlossaryTerm(
      en: 'Motion',
      es: 'Movimiento',
      definitionEn: 'A change of position compared to a reference point.',
      definitionEs: 'Un cambio de posición respecto a un punto de referencia.',
      audioEn: 'audio/en/motion.mp3',
      audioEs: 'audio/es/movimiento.mp3',
    ),
    GlossaryTerm(
      en: 'Reference point',
      es: 'Punto de referencia',
      definitionEn: 'The fixed thing you compare a position against.',
      definitionEs: 'El objeto fijo con el que comparas una posición.',
      audioEn: 'audio/en/reference_point.mp3',
      audioEs: 'audio/es/punto_de_referencia.mp3',
    ),
    GlossaryTerm(
      en: 'Speed',
      es: 'Velocidad',
      definitionEn: 'Distance travelled divided by the time taken.',
      definitionEs: 'La distancia recorrida dividida entre el tiempo empleado.',
      audioEn: 'audio/en/speed.mp3',
      audioEs: 'audio/es/velocidad.mp3',
    ),
    GlossaryTerm(
      en: 'Acceleration',
      es: 'Aceleración',
      definitionEn: 'Any change in speed, up or down.',
      definitionEs:
          'Cualquier cambio de velocidad, hacia arriba o hacia abajo.',
      audioEn: 'audio/en/acceleration.mp3',
      audioEs: 'audio/es/aceleracion.mp3',
    ),
  ],
  questions: [
    Question(
      id: 'q1',
      promptEs: 'Corres 60 metros en 10 segundos. ¿Cuál es tu velocidad media?',
      optionsEs: [
        '6 metros por segundo',
        '10 metros por segundo',
        '600 metros por segundo',
        '0,6 metros por segundo',
      ],
      explanationEs:
          'La velocidad media es la distancia dividida entre el tiempo. '
          '60 metros divididos entre 10 segundos son 6 metros por segundo.',
      explanation:
          'Speed is distance divided by time. 60 metres shared over 10 seconds is 6 metres in every second.',
      prompt: 'You run 60 metres in 10 seconds. What is your average speed?',
      options: [
        '6 metres per second',
        '10 metres per second',
        '600 metres per second',
        '0.6 metres per second',
      ],
      answer: 0,
    ),
    Question(
      id: 'q2',
      promptEs:
          'Mientras estás sentado sin moverte dentro de un tren en marcha, '
          'estás en movimiento con respecto a...',
      optionsEs: [
        'Un árbol fuera del tren',
        'Tu asiento',
        'Tu mochila',
        'La ventana',
      ],
      explanationEs:
          'El movimiento se describe respecto a un punto de referencia. '
          'El asiento y la mochila viajan contigo, pero el árbol no. '
          'Por eso te mueves respecto al árbol.',
      explanation:
          'Motion is always measured against a reference point. The seat and your bag travel with you, so you are still compared to them. The tree stays behind, so compared to it you are moving.',
      prompt:
          'Sitting still on a moving train, you are in motion compared to...',
      options: ['A tree outside', 'Your seat', 'Your bag', 'The window'],
      answer: 0,
    ),
    Question(
      id: 'q3',
      promptEs:
          'Un ciclista frena al llegar a una curva. Esto es un ejemplo de...',
      optionsEs: [
        'Aceleración',
        'Velocidad constante',
        'Ausencia de movimiento',
        'Un punto de referencia',
      ],
      explanationEs:
          'La aceleración incluye cualquier cambio de velocidad, también '
          'una reducción. Al frenar, cambia la velocidad del ciclista.',
      explanation:
          'Acceleration means any change of speed, including slowing down. Braking changes the cyclist\'s speed, so it counts.',
      prompt: 'A cyclist brakes at a corner. This is an example of...',
      options: [
        'Acceleration',
        'Constant speed',
        'No motion',
        'A reference point',
      ],
      answer: 0,
    ),
    Question(
      id: 'q4',
      promptEs:
          'La velocidad es la distancia recorrida dividida entre el ___ transcurrido.',
      optionsEs: ['tiempo', 'fuerza', 'masa', 'peso'],
      explanationEs:
          'La velocidad media se calcula dividiendo la distancia entre el tiempo.',
      explanation:
          'The formula is speed = distance divided by time. Force and mass belong to other formulas.',
      kind: QuestionKind.blank,
      prompt: 'Speed is the distance travelled divided by the ___ taken.',
      options: ['time', 'force', 'mass', 'weight'],
      answer: 0,
    ),
    Question(
      id: 'q5',
      promptEs: 'Tres de estas son unidades de velocidad. ¿Cuál no lo es?',
      optionsEs: [
        'kilogramos',
        'metros por segundo',
        'kilómetros por hora',
        'millas por hora',
      ],
      explanationEs:
          'Los kilogramos miden masa. Las unidades de velocidad combinan distancia y tiempo.',
      explanation:
          'Every unit of speed is a distance over a time, like metres per second. Kilograms measure mass, not speed.',
      kind: QuestionKind.oddOneOut,
      prompt: 'Three of these are units of speed. Which one is not?',
      options: [
        'kilograms',
        'metres per second',
        'kilometres per hour',
        'miles per hour',
      ],
      answer: 0,
    ),
    Question(
      id: 'q6',
      promptEs: 'Relaciona cada palabra con su significado.',
      explanationEs:
          'Cada término describe una idea distinta: movimiento, velocidad, cambio de velocidad o referencia.',
      explanation:
          'Each term describes a different idea: what movement is, how fast it happens, and what you measure it against.',
      kind: QuestionKind.match,
      prompt: 'Match each word to what it means.',
      points: 20,
      pairs: [
        MatchPair(
          left: 'Speed',
          right: 'Distance ÷ time',
          leftEs: 'Velocidad',
          rightEs: 'Distancia ÷ tiempo',
        ),
        MatchPair(
          left: 'Motion',
          right: 'A change of position',
          leftEs: 'Movimiento',
          rightEs: 'Un cambio de posición',
        ),
        MatchPair(
          left: 'Acceleration',
          right: 'A change of speed',
          leftEs: 'Aceleración',
          rightEs: 'Un cambio de velocidad',
        ),
        MatchPair(
          left: 'Reference point',
          right: 'What you measure against',
          leftEs: 'Punto de referencia',
          rightEs: 'La referencia con la que comparas la posición',
        ),
      ],
    ),
    Question(
      id: 'q7',
      promptEs:
          'Un carrito de juguete avanza a una velocidad constante de '
          '4 metros por segundo durante 6 segundos. ¿Qué distancia recorre?',
      optionsEs: ['1,5 metros', '10 metros', '24 metros', '40 metros'],
      explanationEs:
          'La distancia es la velocidad multiplicada por el tiempo: '
          '4 por 6 = 24 metros.',
      prompt:
          'A toy car moves at a constant 4 metres per second for 6 seconds. '
          'How far does it travel?',
      options: ['1.5 metres', '10 metres', '24 metres', '40 metres'],
      answer: 2,
      explanation:
          'Distance is speed multiplied by time: 4 times 6 = 24 metres.',
    ),
    Question(
      id: 'q8',
      promptEs:
          'Maya y Luis recorren 24 metros cada uno. Maya tarda 6 segundos '
          'y Luis tarda 8 segundos. ¿Quién tiene mayor velocidad media?',
      optionsEs: [
        'Luis',
        'Maya',
        'Tienen la misma velocidad media',
        'Se necesitan sus masas para compararlos',
      ],
      explanationEs:
          'Maya recorre 24 dividido entre 6 = 4 metros por segundo. '
          'Luis recorre 24 dividido entre 8 = 3 metros por segundo. '
          'Por eso Maya es más rápida.',
      prompt:
          'Maya and Luis each run 24 metres. Maya takes 6 seconds and Luis '
          'takes 8 seconds. Who has the greater average speed?',
      options: [
        'Luis',
        'Maya',
        'They have the same average speed',
        'Their masses are needed to compare them',
      ],
      answer: 1,
      explanation:
          'Maya averages 24 divided by 6 = 4 metres per second. Luis averages '
          '24 divided by 8 = 3 metres per second, so Maya is faster.',
    ),
    Question(
      id: 'q9',
      promptEs:
          'En una gráfica de distancia frente al tiempo, '
          '¿qué indica una línea horizontal?',
      optionsEs: [
        'El objeto aumenta su velocidad',
        'El objeto se mueve a una velocidad constante distinta de cero',
        'El objeto no se mueve',
        'La distancia aumenta',
      ],
      explanationEs:
          'Una línea horizontal indica que pasa el tiempo pero la '
          'distancia no cambia. El objeto está en reposo durante ese intervalo.',
      prompt: 'On a distance-time graph, what does a horizontal line show?',
      options: [
        'The object is speeding up',
        'The object is moving at a steady nonzero speed',
        'The object is not moving',
        'The distance is increasing',
      ],
      answer: 2,
      explanation:
          'A horizontal line means time passes but the distance does not '
          'change. The object is at rest during that interval.',
    ),
    Question(
      id: 'q10',
      promptEs:
          'En la misma gráfica de distancia frente al tiempo, la línea '
          'recta A sube con mayor pendiente que la línea B. ¿Qué significa?',
      optionsEs: [
        'El objeto B tiene mayor velocidad',
        'Ambos objetos tienen la misma velocidad',
        'El objeto A necesariamente se mueve hacia atrás',
        'El objeto A tiene mayor velocidad',
      ],
      explanationEs:
          'En los mismos ejes de distancia y tiempo, una mayor pendiente '
          'hacia arriba indica más distancia en el mismo tiempo y, por tanto, '
          'mayor velocidad.',
      prompt:
          'Two straight lines are drawn on the same distance-time graph. '
          'Line A slopes upward more steeply than line B. What does this mean?',
      options: [
        'Object B has the greater speed',
        'Both objects have the same speed',
        'Object A must be moving backward',
        'Object A has the greater speed',
      ],
      answer: 3,
      explanation:
          'On the same distance-time axes, a steeper upward line shows '
          'more distance covered in the same time, so the speed is greater.',
    ),
    Question(
      id: 'q11',
      promptEs:
          'Un caminante ha recorrido 0 metros a los 0 segundos, 6 metros '
          'a los 2 segundos y 12 metros a los 4 segundos. '
          '¿Qué muestran estas mediciones?',
      optionsEs: [
        'Una velocidad media de 3 metros por segundo en cada intervalo',
        'Una velocidad que aumenta en cada intervalo',
        'Una velocidad que disminuye en cada intervalo',
        'Ausencia de movimiento en ambos intervalos',
      ],
      explanationEs:
          'El caminante recorre 6 metros en cada intervalo de 2 segundos. '
          'Cada intervalo tiene una velocidad media de 6 dividido entre '
          '2 = 3 metros por segundo.',
      prompt:
          'A walker travels 0 metres at 0 seconds, 6 metres at 2 seconds, '
          'and 12 metres at 4 seconds. What do these measurements show?',
      options: [
        'An average speed of 3 metres per second in each interval',
        'An increasing speed in each interval',
        'A decreasing speed in each interval',
        'No motion in either interval',
      ],
      answer: 0,
      explanation:
          'The walker covers 6 metres in each 2-second interval. Each '
          'interval has an average speed of 6 divided by 2 = 3 metres per second.',
    ),
    Question(
      id: 'q12',
      promptEs:
          'Un auto avanza por una carretera recta y pasa de 2 a '
          '6 metros por segundo. ¿Qué describe este cambio?',
      optionsEs: [
        'Su velocidad permanece constante',
        'Se detiene',
        'Aumenta su velocidad',
        'La distancia recorrida sigue siendo cero',
      ],
      explanationEs:
          'La velocidad aumenta de 2 a 6 metros por segundo. '
          'Aumentar la velocidad es un ejemplo de aceleración.',
      prompt:
          'A car moving along a straight road changes from 2 metres per '
          'second to 6 metres per second. Which statement describes the change?',
      options: [
        'Its speed stays constant',
        'It comes to a stop',
        'It speeds up',
        'Its distance travelled stays zero',
      ],
      answer: 2,
      explanation:
          'The speed increases from 2 to 6 metres per second. Increasing '
          'speed is one example of acceleration.',
    ),
    Question(
      id: 'q13',
      promptEs:
          '¿Qué dos mediciones se necesitan para calcular la '
          'velocidad media de un carrito de juguete?',
      optionsEs: [
        'Masa y altura',
        'Fuerza y masa',
        'Temperatura y distancia',
        'Distancia recorrida y tiempo transcurrido',
      ],
      explanationEs:
          'La velocidad media es la distancia total recorrida dividida '
          'entre el tiempo transcurrido. No se necesitan la masa, '
          'la fuerza ni la temperatura para este cálculo.',
      prompt:
          'Which two measurements are needed to find a toy car\'s average speed?',
      options: [
        'Mass and height',
        'Force and mass',
        'Temperature and distance',
        'Distance travelled and elapsed time',
      ],
      answer: 3,
      explanation:
          'Average speed is total distance travelled divided by elapsed '
          'time. Mass, force, and temperature are not needed for this calculation.',
    ),
    ...motionPracticeQuestions,
  ],
);
