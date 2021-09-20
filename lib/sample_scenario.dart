import 'package:andax/models/actor.dart';
import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/scenario.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final testScenario = Scenario(
    metaData: ContentMetaData(
      id: 'tatar',
      lastUpdateAt: Timestamp.now(),
    ),
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
  ActorTranslation(name: 'Friend', metaData: ContentMetaData(id: 'bot')),
  ActorTranslation(name: 'You', metaData: ContentMetaData(id: 'player')),
  ScenarioTranslation(
    title: 'Meeting with friend',
    metaData: ContentMetaData(
      id: 'tatar',
      lastUpdateAt: Timestamp.now(),
    ),
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'greeting'),
    text: 'Assalamu Alaykum!',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't1'),
    text: 'Waalakum Assalam!',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't2'),
    text: 'Hi!',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'how-are-you'),
    text: 'How are you doing?',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't3'),
    text: 'How are you doing?',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't4'),
    text: 'I am doing fine',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't5'),
    text: 'Normal',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't6'),
    text: 'I am sad :(',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'glad-to-hear'),
    text: 'I am glad to hear that :)',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't7'),
    text: 'I am glad to hear that :)',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'whats-wrong'),
    text: 'Oh no! What is wrong?',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't9'),
    text: 'Oh no! What is wrong?',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't11'),
    text: 'I ran out of tea',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't12'),
    text: 'I do not want to talk',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'come-for-tea'),
    text: 'Come over. I have tea and chakchak',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't10'),
    text: 'Come over. I have tea and chakchak',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'will-bring'),
    text: 'I will come over. I will bring tea and Chakchak',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't13'),
    text: 'I will come over. I will bring tea and Chakchak',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't15'),
    text: 'No. I hate Chakchak!',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't16'),
    text: 'Awesome! You are a good friend',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'lose'),
    text: ':(',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'win'),
    text: ':D',
  ),
];

final testTranslationsRu = <TranslationAsset>[
  ActorTranslation(
    name: 'Friend',
    metaData: ContentMetaData(id: 'bot'),
  ),
  ActorTranslation(
    name: 'You',
    metaData: ContentMetaData(id: 'player'),
  ),
  ScenarioTranslation(
    title: 'Встреча с другом',
    metaData: ContentMetaData(
      id: 'tatar',
      lastUpdateAt: Timestamp.now(),
    ),
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'greeting'),
    text: 'Ассаламу алейкум!',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'salam'),
    text: 'Ваалейкум ассалам!',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't1'),
    text: 'Ваалейкум ассалам!',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'hi'),
    text: 'Привет!',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't2'),
    text: 'Привет!',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'how-are-you'),
    text: 'Как поживаешь?',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't3'),
    text: 'Как поживаешь?',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'happy'),
    text: 'Всё впорядке.',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't4'),
    text: 'Всё впорядке.',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'normal'),
    text: 'Нормально',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't5'),
    text: 'Нормально',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'sad'),
    text: 'Не очень :(',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't6'),
    text: 'Не очень :(',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'glad-to-hear'),
    text: 'Рад это слышать :)',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't7'),
    text: 'Рад это слышать :)',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'whats-wrong'),
    text: 'Мне жаль! Что случилось?',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't9'),
    text: 'Мне жаль! Что случилось?',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'out-of-tea'),
    text: 'У меня закончился чай',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'out-of-tea'),
    text: 'У меня закончился чай',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't11'),
    text: 'У меня закончился чай',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'wont-talk'),
    text: 'Я не хочу говорить об этом',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't12'),
    text: 'Я не хочу говорить об этом',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'come-for-tea'),
    text: 'Пошли, у меня есть чай с чак-чаком',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't10'),
    text: 'Пошли, у меня есть чай с чак-чаком',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'will-bring'),
    text: 'Спасибо, я присоединюсь и принесу чай с чакчаком',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'hate-chakchak'),
    text: 'Не-а. Я терпеть не могу чак-чак!',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't15'),
    text: 'Не-а. Я терпеть не могу чак-чак!',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'thank-you'),
    text: 'Замечательно! Ты хороший друг',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 't16'),
    text: 'Замечательно! Ты хороший друг',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'lose'),
    text: ':(',
  ),
  MessageTranslation(
    metaData: ContentMetaData(id: 'win'),
    text: ':D',
  ),
];
