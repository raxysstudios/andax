import 'package:andax/scenarios/data/actor.dart';
import 'package:andax/scenarios/data/translation_asset.dart';
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
      translations: [
        TranslationAsset(id: '0', text: 'Hello'),
        TranslationAsset(id: '1', text: 'How are you?'),
        TranslationAsset(id: '2-1', text: 'Fine, thanks.'),
        TranslationAsset(id: '2-2', text: 'Ugh, been hard lately.'),
        TranslationAsset(id: '3', text: 'Good to hear!'),
        TranslationAsset(id: '4', text: "Oh, I'm sorry"),
      ],
    );
  }
}
