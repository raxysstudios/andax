import 'dart:async';
import "dart:math";
import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/scenario.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/utils.dart';
import 'package:andax/widgets/happiness_slider.dart';
import 'package:andax/widgets/node_card.dart';
import 'package:flutter/material.dart';

class PlayScreen extends StatefulWidget {
  final Scenario scenario;
  final List<TranslationAsset> translations;

  const PlayScreen({
    required this.scenario,
    required this.translations,
  });

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final Map<String, Node> nodes;
  late final Map<String, TranslationAsset> translations;
  late final Map<String, Actor> actors;
  late Node currentNode;
  final List<Node> storyline = [];
  int totalScore = 50;

  Timer? autoAdvance;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    nodes = {
      for (final node in widget.scenario.nodes) node.id: node,
    };
    translations = {
      for (final translation in widget.translations)
        translation.metaData.id: translation,
    };
    currentNode = nodes[widget.scenario.startNodeId]!;
    actors = {
      for (final actor in widget.scenario.actors) actor.id: actor,
    };

    if (currentNode.autoTransition && currentNode.transitions != null)
      moveAuto(currentNode.transitions!);
  }

  void advanceStory(Transition transition) {
    setState(() {
      autoAdvance?.cancel();
      storyline.add(currentNode);
      totalScore += transition.score;
      currentNode = nodes[transition.targetNodeId]!;
      if (currentNode.endingType != null) isFinished = true;
      if (currentNode.autoTransition && currentNode.transitions != null)
        moveAuto(currentNode.transitions!);
    });
  }

  void moveAuto(List<Transition> transition) {
    autoAdvance?.cancel();
    autoAdvance = Timer(
      Duration(milliseconds: 500),
      () {
        final index = Random().nextInt(transition.length);
        advanceStory(transition[index]);
        autoAdvance = null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Center(child: Text('Score: $totalScore')),
          HappinessSlider(value: totalScore),
          for (var i = 0; i < storyline.length; i++)
            NodeCard(
              node: storyline[i],
              previousNode: i > 0 ? storyline[i - 1] : null,
              translations: translations,
              actors: actors,
            ),
          NodeCard(
            node: currentNode,
            previousNode: storyline.isEmpty ? null : storyline.last,
            translations: translations,
            actors: actors,
          ),
          if (currentNode.transitions != null && autoAdvance == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final transition in currentNode.transitions!)
                    OutlinedButton(
                      onPressed: () => advanceStory(transition),
                      child: Text(
                        getTranslation<MessageTranslation>(
                          translations,
                          transition.id,
                          (t) => t.text,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (isFinished)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  currentNode.endingType == EndingType.win
                      ? 'End of scenario.'
                      : 'You lost! :(',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
