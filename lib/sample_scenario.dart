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
        id: 'greeting',
        actorId: 'bot',
        transitions: [
          Transition(id: 't1', targetNodeId: 'salam', score: 15),
          Transition(id: 't2', targetNodeId: 'hi', score: -10),
        ],
      ),
      Node(
        id: 'salam',
        actorId: 'player',
        transitions: [
          Transition(id: 't3', targetNodeId: 'how-are-you'),
        ],
      ),
      Node(
        id: 'hi',
        actorId: 'player',
        transitions: [
          Transition(id: 't3', targetNodeId: 'how-are-you'),
        ],
      ),
      Node(id: 'how-are-you', actorId: 'bot', transitions: [
        Transition(id: 't4', targetNodeId: 'happy', score: 10),
        Transition(id: 't5', targetNodeId: 'normal', score: 0),
        Transition(id: 't6', targetNodeId: 'sad', score: -5),
      ]),
      Node(id: 'happy', actorId: 'player', autoTransition: true, transitions: [
        Transition(id: 't7', targetNodeId: 'glad-to-hear'),
      ]),
      Node(id: 'normal', actorId: 'player', autoTransition: true, transitions: [
        Transition(id: 't8', targetNodeId: 'glad-to-hear'),
      ]),
      Node(id: 'sad', actorId: 'player', autoTransition: true, transitions: [
        Transition(id: 't9', targetNodeId: 'whats-wrong'),
      ]),
      Node(
          id: 'glad-to-hear',
          actorId: 'bot',
          autoTransition: true,
          transitions: [
            Transition(id: 't10', targetNodeId: 'come-for-tea'),
          ]),
      Node(
        id: 'whats-wrong',
        actorId: 'bot',
        transitions: [
          Transition(id: 't11', targetNodeId: 'out-of-tea', score: 5),
          Transition(id: 't12', targetNodeId: 'wont-talk', score: -30),
        ],
      ),
      Node(
        id: 'out-of-tea',
        actorId: 'player',
        transitions: [
          Transition(id: 't13', targetNodeId: 'will-bring'),
        ],
      ),
      Node(
        id: 'wont-talk',
        actorId: 'player',
        autoTransition: true,
        transitions: [
          Transition(id: 't14', targetNodeId: 'lose'),
        ],
      ),
      Node(
        id: 'come-for-tea',
        actorId: 'bot',
        transitions: [
          Transition(id: 't15', targetNodeId: 'hate-chakchak', score: -70),
          Transition(id: 't16', targetNodeId: 'thank-you', score: 15),
        ],
      ),
      Node(
        id: 'will-bring',
        actorId: 'bot',
        transitions: [
          Transition(id: 't15', targetNodeId: 'hate-chakchak', score: -70),
          Transition(id: 't16', targetNodeId: 'thank-you', score: 15),
        ],
      ),
      Node(
        id: 'hate-chakchak',
        actorId: 'player',
        autoTransition: true,
        transitions: [
          Transition(id: 't17', targetNodeId: 'lose'),
        ],
      ),
      Node(
        id: 'thank-you',
        actorId: 'player',
        autoTransition: true,
        transitions: [
          Transition(id: 't18', targetNodeId: 'win'),
        ],
      ),
      Node(id: 'lose', endingType: EndingType.loss),
      Node(id: 'win', endingType: EndingType.win),
    ]);

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
    metaData: ContentMetaData('tatar'),
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
    text: ':(',
  ),
  MessageTranslation(
    metaData: ContentMetaData('win'),
    text: ':D',
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
    metaData: ContentMetaData('tatar'),
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
    text: ':(',
  ),
  MessageTranslation(
    metaData: ContentMetaData('win'),
    text: ':D',
  ),
];
