import 'dart:async';
import "dart:math";
import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/scenario.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:flutter/material.dart';
import '../models/choice.dart';

class PlayScreen extends StatefulWidget {
  final Scenario scenario;
  final List<MessageAsset> translations;

  const PlayScreen({
    required this.scenario,
    required this.translations,
  });

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final Map<String, Node> nodes;
  late final Map<String, MessageAsset> translations;
  late final Map<String, Actor> actors;
  late Node currentNode;
  final List<Node> storyline = [];

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

  void advanceStory([Choice? choice]) {
    setState(() {
      autoAdvance?.cancel();
      storyline.add(currentNode);
      currentNode = nodes[choice!.targetNodeId]!;
      if (currentNode.endingType != null) isFinished = true;
      if (currentNode.autoTransition && currentNode.transitions != null)
        moveAuto(currentNode.transitions!);
    });
  }

  void moveAuto(List<Choice> choices) {
    autoAdvance?.cancel();
    autoAdvance = Timer(
      Duration(milliseconds: 500),
      () {
        final index = Random().nextInt(choices.length);
        advanceStory(choices[index]);
        autoAdvance = null;
      },
    );
  }

  String getTextTranslation(String id) {
    final translation = translations[id];
    if (translation == null) return '!!! no translation !!!';
    return translation.text;
  }

  Widget buildNode(Node node, int index) {
    final actor = actors[node.actorId];
    final translation = translations[node.id];
    if (translation == null) return SizedBox();

    final isPlayer = actor?.type == ActorType.player;
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
          if (currentNode.transitions != null && autoAdvance == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final choice in currentNode.transitions!)
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
