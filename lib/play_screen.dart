import "dart:math";
import 'package:andax/scenarios/data/actor.dart';
import 'package:andax/scenarios/data/node.dart';
import 'package:andax/scenarios/data/scenario.dart';
import 'package:andax/scenarios/data/translation_asset.dart';
import 'package:flutter/material.dart';
import 'scenarios/data/choice.dart';

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

  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    nodes = {
      for (final node in widget.scenario.nodes) node.id: node,
    };
    translations = {
      for (final translation in widget.translations)
        translation.id: translation,
    };
    currentNode = nodes[widget.scenario.startNodeId]!;
    actors = {
      for (final actor in widget.scenario.actors) actor.id: actor,
    };
  }

  void advanceStory([Choice? choice]) {
    if (choice == null) {
      final choices = currentNode.choices;
      final index = Random().nextInt(choices!.length);
      choice = choices[index];
    }
    setState(() {
      storyline.add(currentNode);
      currentNode = nodes[choice!.targetNodeId]!;
      if (currentNode.endingType != null) isFinished = true;
    });
  }

  String getTextTranslation(String id) {
    final translation = translations[id];
    if (translation == null) return '!!! no translation !!!';
    return translation.text ?? '';
  }

  Widget buildNode(Node node, int index) {
    final actor = actors[node.actorId];
    final translation = translations[node.id];
    if (translation == null) return SizedBox();

    final isPlayer = actor?.isPlayer ?? false;
    final printActor = actor != null &&
        (index == 0 || storyline[index - 1].actorId != actor.id);
    return Padding(
      padding: isPlayer
          ? const EdgeInsets.only(left: 32)
          : const EdgeInsets.only(right: 32),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment:
                isPlayer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (printActor)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    getTextTranslation(actor!.id),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          for (var i = 0; i < storyline.length; i++) buildNode(storyline[i], i),
          buildNode(currentNode, storyline.length),
          if (currentNode.choices != null)
            if (currentNode.autoChoice)
              IconButton(
                onPressed: advanceStory,
                icon: Icon(Icons.check_outlined),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final choice in currentNode.choices!)
                      OutlinedButton(
                        onPressed: () => advanceStory(choice),
                        child: Text(getTextTranslation(choice.id)),
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
                      ? 'You won! :)'
                      : 'You lost! :(',
                ),
              ),
            )
        ],
      ),
    );
  }
}
