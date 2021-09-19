import 'package:andax/models/actor.dart';
import 'package:flutter/material.dart';
import 'play_screen.dart';
import '../models/transition.dart';
import '../models/content_meta_data.dart';
import '../models/node.dart';
import '../models/scenario.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlayScreen(
      scenario: Scenario(
        nodes: [
          Node(
            id: '0',
            actorId: 'a1',
            transitions: [
              Transition(
                id: '0-1',
                targetNodeId: '1',
              ),
            ],
            autoTransition: true,
          ),
          Node(
            id: '1',
            actorId: 'a1',
            transitions: [
              Transition(
                id: '1-1',
                targetNodeId: '2',
              ),
            ],
            autoTransition: true,
          ),
          Node(
            id: '2',
            actorId: 'a2',
            transitions: [
              Transition(
                id: '2-1',
                targetNodeId: '3',
              ),
              Transition(
                id: '2-2',
                targetNodeId: '4',
              ),
            ],
          ),
          Node(
            id: '3',
            actorId: 'a2',
            transitions: [
              Transition(
                id: '3-1',
                targetNodeId: '5',
              ),
            ],
            autoTransition: true,
          ),
          Node(
            id: '4',
            actorId: 'a2',
            transitions: [
              Transition(
                id: '4-1',
                targetNodeId: '6',
              ),
            ],
            autoTransition: true,
          ),
          Node(
            id: '5',
            actorId: 'a1',
            endingType: EndingType.win,
          ),
          Node(
            id: '6',
            actorId: 'a1',
            endingType: EndingType.loss,
          )
        ],
        startNodeId: '0',
        actors: [
          Actor(id: 'a1'),
          // Actor(id: 'a2', type: true),
        ],
        metaData: ContentMetaData(
          id: '',
          contributorsIds: [],
          lastUpdateAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      ),
      translations: [
        // TranslationAsset(id: '0', text: 'Hello'),
        // TranslationAsset(id: '1', text: 'How are you?'),
        // TranslationAsset(id: '2-1', text: 'Fine'),
        // TranslationAsset(id: '2-2', text: 'Ugh'),
        // TranslationAsset(
        //   id: '3',
        //   text:
        //       'Amazing! We"ve just won the hackaton and people liked our project!',
        // ),
        // TranslationAsset(
        //   id: '4',
        //   text: "Unfortunately, got sick and not feeling good these days.",
        // ),
        // TranslationAsset(id: '5', text: "Great to hear!"),
        // TranslationAsset(id: '6', text: "Oh, I'm sorry."),
        // TranslationAsset(id: 'a1', text: "Friend"),
        // TranslationAsset(id: 'a2', text: "Me"),
      ],
    );
  }
}
