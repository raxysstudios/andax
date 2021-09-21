import 'package:andax/models/actor.dart';
import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/scenario.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';

final testScenario = Scenario(
  metaData: ContentMetaData('tatar'),
  startNodeId: 'greeting',
  actors: [
    Actor(id: 'bot'),
    Actor(id: 'player', type: ActorType.player),
  ],
  nodes: [
    Node(
      'greeting',
      actorId: 'bot',
      transitions: [
        Transition('t1', targetNodeId: 'salam', score: 15),
        Transition('t2', targetNodeId: 'hi', score: -10),
      ],
    ),
    Node(
      'salam',
      actorId: 'player',
      transitions: [
        Transition('t3', targetNodeId: 'how-are-you'),
      ],
    ),
    Node(
      'hi',
      actorId: 'player',
      transitions: [
        Transition('t3', targetNodeId: 'how-are-you'),
      ],
    ),
    Node(
      'how-are-you',
      actorId: 'bot',
      transitions: [
        Transition('t4', targetNodeId: 'happy', score: 10),
        Transition('t5', targetNodeId: 'normal', score: 0),
        Transition('t6', targetNodeId: 'sad', score: -5),
      ],
    ),
    Node(
      'happy',
      actorId: 'player',
      autoTransition: true,
      transitions: [
        Transition('t7', targetNodeId: 'glad-to-hear'),
      ],
    ),
    Node(
      'normal',
      actorId: 'player',
      autoTransition: true,
      transitions: [
        Transition('t8', targetNodeId: 'glad-to-hear'),
      ],
    ),
    Node(
      'sad',
      actorId: 'player',
      autoTransition: true,
      transitions: [
        Transition('t9', targetNodeId: 'whats-wrong'),
      ],
    ),
    Node(
      'glad-to-hear',
      actorId: 'bot',
      autoTransition: true,
      transitions: [
        Transition('t10', targetNodeId: 'come-for-tea'),
      ],
    ),
    Node(
      'whats-wrong',
      actorId: 'bot',
      transitions: [
        Transition('t11', targetNodeId: 'out-of-tea', score: 5),
        Transition('t12', targetNodeId: 'wont-talk', score: -30),
      ],
    ),
    Node(
      'out-of-tea',
      actorId: 'player',
      transitions: [
        Transition('t13', targetNodeId: 'will-bring'),
      ],
    ),
    Node(
      'wont-talk',
      actorId: 'player',
      autoTransition: true,
      transitions: [
        Transition('t14', targetNodeId: 'lose'),
      ],
    ),
    Node(
      'come-for-tea',
      actorId: 'bot',
      transitions: [
        Transition('t15', targetNodeId: 'hate-chakchak', score: -70),
        Transition('t16', targetNodeId: 'thank-you', score: 15),
      ],
    ),
    Node(
      'will-bring',
      actorId: 'bot',
      transitions: [
        Transition('t15', targetNodeId: 'hate-chakchak', score: -70),
        Transition('t16', targetNodeId: 'thank-you', score: 15),
      ],
    ),
    Node(
      'hate-chakchak',
      actorId: 'player',
      autoTransition: true,
      transitions: [
        Transition('t17', targetNodeId: 'lose'),
      ],
    ),
    Node(
      'thank-you',
      actorId: 'player',
    ),
    Node('lose'),
  ],
);

final testTranslations = <TranslationAsset>[
  ActorTranslation(
    name: 'Friend',
    metaData: ContentMetaData('bot'),
  ),
  ActorTranslation(
    name: 'You',
    metaData: ContentMetaData('player'),
  ),
  ScenarioTranslation(
    title: 'Meeting with friend',
    description: 'Chak-Chack and tea, one day from the life of Tatar.',
    metaData: ContentMetaData('scenario'),
  ),
  MessageTranslation(
    metaData: ContentMetaData('greeting'),
    text: 'Assalamu Alaykum!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t1'),
    text: 'Waalakum Assalam!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t2'),
    text: 'Hi!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('how-are-you'),
    text: 'How are you doing?',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t3'),
    text: 'How are you doing?',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t4'),
    text: 'I am doing fine',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t5'),
    text: 'Normal',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t6'),
    text: 'I am sad :(',
  ),
  MessageTranslation(
    metaData: ContentMetaData('glad-to-hear'),
    text: 'I am glad to hear that :)',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t7'),
    text: 'I am glad to hear that :)',
  ),
  MessageTranslation(
    metaData: ContentMetaData('whats-wrong'),
    text: 'Oh no! What is wrong?',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t9'),
    text: 'Oh no! What is wrong?',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t11'),
    text: 'I ran out of tea',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t12'),
    text: 'I do not want to talk',
  ),
  MessageTranslation(
    metaData: ContentMetaData('come-for-tea'),
    text: 'Come over. I have tea and chakchak',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t10'),
    text: 'Come over. I have tea and chakchak',
  ),
  MessageTranslation(
    metaData: ContentMetaData('will-bring'),
    text: 'I will come over. I will bring tea and Chakchak',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t13'),
    text: 'I will come over. I will bring tea and Chakchak',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t15'),
    text: 'No. I hate Chakchak!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t16'),
    text: 'Awesome! You are a good friend',
  ),
  MessageTranslation(
    metaData: ContentMetaData('lose'),
    text: 'One must never say to a Tatar that they hate chack-chack...',
  ),
];

final testTranslationsRu = <TranslationAsset>[
  ActorTranslation(
    name: 'Friend',
    metaData: ContentMetaData('bot'),
  ),
  ActorTranslation(
    name: 'You',
    metaData: ContentMetaData('player'),
  ),
  ScenarioTranslation(
    title: 'Встреча с другом',
    description: 'Чак-чак и чай, один день из жизни татарина.',
    metaData: ContentMetaData('scenario'),
  ),
  MessageTranslation(
    metaData: ContentMetaData('greeting'),
    text: 'Ассаламу алейкум!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('salam'),
    text: 'Ваалейкум ассалам!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t1'),
    text: 'Ваалейкум ассалам!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('hi'),
    text: 'Привет!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t2'),
    text: 'Привет!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('how-are-you'),
    text: 'Как поживаешь?',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t3'),
    text: 'Как поживаешь?',
  ),
  MessageTranslation(
    metaData: ContentMetaData('happy'),
    text: 'Всё впорядке.',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t4'),
    text: 'Всё впорядке.',
  ),
  MessageTranslation(
    metaData: ContentMetaData('normal'),
    text: 'Нормально',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t5'),
    text: 'Нормально',
  ),
  MessageTranslation(
    metaData: ContentMetaData('sad'),
    text: 'Не очень :(',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t6'),
    text: 'Не очень :(',
  ),
  MessageTranslation(
    metaData: ContentMetaData('glad-to-hear'),
    text: 'Рад это слышать :)',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t7'),
    text: 'Рад это слышать :)',
  ),
  MessageTranslation(
    metaData: ContentMetaData('whats-wrong'),
    text: 'Мне жаль! Что случилось?',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t9'),
    text: 'Мне жаль! Что случилось?',
  ),
  MessageTranslation(
    metaData: ContentMetaData('out-of-tea'),
    text: 'У меня закончился чай',
  ),
  MessageTranslation(
    metaData: ContentMetaData('out-of-tea'),
    text: 'У меня закончился чай',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t11'),
    text: 'У меня закончился чай',
  ),
  MessageTranslation(
    metaData: ContentMetaData('wont-talk'),
    text: 'Я не хочу говорить об этом',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t12'),
    text: 'Я не хочу говорить об этом',
  ),
  MessageTranslation(
    metaData: ContentMetaData('come-for-tea'),
    text: 'Пошли, у меня есть чай с чак-чаком',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t10'),
    text: 'Пошли, у меня есть чай с чак-чаком',
  ),
  MessageTranslation(
    metaData: ContentMetaData('will-bring'),
    text: 'Спасибо, я присоединюсь и принесу чай с чакчаком',
  ),
  MessageTranslation(
    metaData: ContentMetaData('hate-chakchak'),
    text: 'Не-а. Я терпеть не могу чак-чак!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t15'),
    text: 'Не-а. Я терпеть не могу чак-чак!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('thank-you'),
    text: 'Замечательно! Ты хороший друг',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t16'),
    text: 'Замечательно! Ты хороший друг',
  ),
  MessageTranslation(
    metaData: ContentMetaData('lose'),
    text: 'Никогда не стоит говорить татарину что вы ненавидите чак-чак...',
  ),
];

final testTranslationsTa = <TranslationAsset>[
  ActorTranslation(
    name: 'Дус',
    metaData: ContentMetaData('bot'),
  ),
  ActorTranslation(
    name: 'Син',
    metaData: ContentMetaData('player'),
  ),
  ScenarioTranslation(
    title: 'Бер-беребез белән очрашу',
    description: 'Чәк-чәк һәм чәй, татар тормышыннан бер көн.',
    metaData: ContentMetaData('scenario'),
  ),
  MessageTranslation(
    metaData: ContentMetaData('greeting'),
    text: 'Ассаламу әләйкум!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('salam'),
    text: 'Валейкум ассалам!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t1'),
    text: 'Валейкум ассалам!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('hi'),
    text: 'Сәлам!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t2'),
    text: 'Сәлам!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('how-are-you'),
    text: 'Ничек яшисең?',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t3'),
    text: 'Ничек яшисең?',
  ),
  MessageTranslation(
    metaData: ContentMetaData('happy'),
    text: 'Барысы да тәртиптә.',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t4'),
    text: 'Барысы да тәртиптә.',
  ),
  MessageTranslation(
    metaData: ContentMetaData('normal'),
    text: 'Җирендә.',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t5'),
    text: 'Җирендә.',
  ),
  MessageTranslation(
    metaData: ContentMetaData('sad'),
    text: 'Бик яхшы :(',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t6'),
    text: 'Бик яхшы :(',
  ),
  MessageTranslation(
    metaData: ContentMetaData('glad-to-hear'),
    text: 'Моны ишетүемә шатмын :)',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t7'),
    text: 'Моны ишетүемә шатмын :)',
  ),
  MessageTranslation(
    metaData: ContentMetaData('whats-wrong'),
    text: 'Миңа кызганыч! Ни булды?',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t9'),
    text: 'Миңа кызганыч! Ни булды?',
  ),
  MessageTranslation(
    metaData: ContentMetaData('out-of-tea'),
    text: 'Минем чәй тәмамланды.',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t11'),
    text: 'Минем чәй тәмамланды.',
  ),
  MessageTranslation(
    metaData: ContentMetaData('wont-talk'),
    text: 'Мин дә бу хакта сөйләргә теләмим.',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t12'),
    text: 'Мин дә бу хакта сөйләргә теләмим.',
  ),
  MessageTranslation(
    metaData: ContentMetaData('come-for-tea'),
    text: 'Китте, чәк-чәк белән чәй бар.',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t10'),
    text: 'Китте, чәк-чәк белән чәй бар.',
  ),
  MessageTranslation(
    metaData: ContentMetaData('will-bring'),
    text: 'Рәхмәт, мин дә кушылам һәм чәк-чәк белән чәй алып кайтам.',
  ),
  MessageTranslation(
    metaData: ContentMetaData('hate-chakchak'),
    text: 'Юк, мин чәк-чәккә түзә алмыйм!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t15'),
    text: 'Юк, мин чәк-чәккә түзә алмыйм!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('thank-you'),
    text: 'Искиткеч! Син яхшы дус!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('t16'),
    text: 'Искиткеч! Син яхшы дус!',
  ),
  MessageTranslation(
    metaData: ContentMetaData('lose'),
    text: 'Татарча беркайчан да әйтергә кирәкми, сез чәк-чәкне ненавидите...',
  ),
];

final presetScenario = testTranslations;
