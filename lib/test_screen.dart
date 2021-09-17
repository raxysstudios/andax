import 'package:flutter/material.dart';
import 'play_screen.dart';
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
            choices: [
              Choice(
                id: '1',
                targetNodeId: '2',
              ),
            ],
          ),
          Node(
            id: '2',
            choices: [
              Choice(
                id: '3',
                targetNodeId: '5',
              ),
              Choice(
                id: '4',
                targetNodeId: '6',
              ),
            ],
          ),
          Node(
            id: '5',
            endingType: EndingType.win,
          ),
          Node(
            id: '6',
            endingType: EndingType.loss,
          )
        ],
        startNodeId: '0',
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
          '2': 'How are you?',
          '3': 'Great!',
          '4': 'Not so well...',
          '5': 'Good to hear!',
          '6': 'Oh, I\'m sorry!',
        },
      ),
    );
  }
}
