import 'dart:async';
import "dart:math";
import 'package:andax/scenarios/data/actor.dart';
import 'package:andax/scenarios/data/node.dart';
import 'package:andax/scenarios/data/scenario.dart';
import 'package:andax/scenarios/data/translation_set.dart';
import 'package:flutter/material.dart';
import 'scenarios/data/choice.dart';

class PlayScreen extends StatefulWidget {
  final Scenario scenario;
  final TranslationSet texts;

  const PlayScreen({
    required this.scenario,
    required this.texts,
  });

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final Map<String, Node> allNodes;
  late final Map<String, Actor> allActors;
  late Node currentNode;
  final List<Node> storyline = [];

  Timer? autoAdvance;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    allNodes = {
      for (final node in widget.scenario.nodes) node.id: node,
    };
    currentNode = allNodes[widget.scenario.startNodeId]!;
    allActors = widget.scenario.actors == null
        ? {}
        : {
            for (final actor in widget.scenario.actors!) actor.id: actor,
          };
  }

  void advanceStory(Choice choice) {
    setState(() {
      autoAdvance = null;
      storyline.add(currentNode);
      currentNode = allNodes[choice.id]!;

      if (currentNode.endingType == null) {
        final choices = currentNode.choices;
        if (currentNode.autoChoice && autoAdvance == null) {
          final index = Random().nextInt(choices!.length);
          autoAdvance = Timer(
            Duration(milliseconds: 250),
            () => advanceStory(choices[index]),
          );
        }
      } else
        isFinished = true;
    });
  }

  String getTextTranslation(String id, {showError = false}) {
    return widget.texts.assets[id] ??
        (showError ? '!!! no translation !!!' : '');
  }

  Widget buildNode(Node node) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            if (node.actorId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  getTextTranslation(node.actorId!),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Text(
              getTextTranslation(node.id),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          for (final node in storyline) ...[
            buildNode(node),
            const Divider(height: 0),
          ],
          buildNode(currentNode),
          if (currentNode.choices != null && autoAdvance == null)
            for (final choice in currentNode.choices!)
              TextButton(
                onPressed: () => advanceStory(choice),
                child: Text(getTextTranslation(choice.id)),
              ),
          const Divider(height: 0),
          if (isFinished)
            Text(
              currentNode.endingType == EndingType.win
                  ? 'You won! :)'
                  : 'You lost! :(',
            )
        ],
      ),
    );
  }
}
