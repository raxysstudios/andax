import 'package:andax/scenarios/data/actor.dart';
import 'package:flutter/material.dart';
import 'play_screen.dart';
import 'scenarios/data/choice.dart';
import 'scenarios/data/content_meta_data.dart';
import 'scenarios/data/node.dart';
import 'scenarios/data/scenario.dart';
import 'scenarios/data/translation_set.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlayScreen(
      scenario: Scenario(
        nodes: [
          Node(
            id: '0',
            actorId: 'a1',
            choices: [
              Choice(
                id: '0-1',
                targetNodeId: '1',
              ),
            ],
            autoChoice: true,
          ),
          Node(
            id: '1',
            actorId: 'a1',
            choices: [
              Choice(
                id: '1-1',
                targetNodeId: '2',
              ),
            ],
            autoChoice: true,
          ),
          Node(
            id: '2',
            actorId: 'a2',
            choices: [
              Choice(
                id: '2-1',
                targetNodeId: '3',
              ),
              Choice(
                id: '2-2',
                targetNodeId: '4',
              ),
            ],
          ),
          Node(
            id: '3',
            actorId: 'a1',
            endingType: EndingType.win,
          ),
          Node(
            id: '4',
            actorId: 'a1',
            endingType: EndingType.loss,
          )
        ],
        startNodeId: '0',
        actors: [
          Actor(id: 'a1'),
          Actor(id: 'a2', isPlayer: true),
        ],
        metaData: ContentMetaData(
          id: '',
          contributorsIds: [],
          lastUpdateAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      ),
      texts: TranslationSet(
        language: 'english',
        type: TranslationType.text,
        metaData: ContentMetaData(
          id: '',
          contributorsIds: [],
          lastUpdateAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
        assets: {
          '0': 'Hey!',
          '1': 'How are you?',
          '2': 'Something something!',
          '2-1': 'Great!',
          '2-2': 'Not so well...',
          '3': 'Good to hear!',
          '4': 'Oh, I\'m sorry!',
          'a1': 'Friend',
          'a2': 'Another friend',
        },
      ),
    );
  }
}
