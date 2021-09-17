import 'dart:async';
import 'package:andax/scenarios/data/node.dart';
import 'package:andax/scenarios/data/scenario.dart';
import 'package:andax/scenarios/data/translation_set.dart';
import 'package:flutter/material.dart';

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
  late Node currentNode;
  final List<Node> storyline = [];

  Timer? autoMove;

  @override
  void initState() {
    super.initState();
    allNodes = {
      for (final node in widget.scenario.nodes) node.id: node,
    };
    currentNode = allNodes[widget.scenario.startNodeId]!;
  }

  void advanceStory(Choice choice) {
    setState(() {
      autoMove = null;
      storyline.add(currentNode);
      currentNode = allNodes[choice.id]!;
    });
  }

  String getTextTranslation(String id, {showError = false}) {
    return widget.texts.assets[id] ??
        (showError ? '!!! no translation !!!' : '');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final node in storyline) Text(getTextTranslation(node.id)),
        Builder(builder: (context) {
          final choices = currentNode.choices;

          if (choices != null && choices.length == 1 && autoMove == null) {
            final choice = choices.first;
            if (getTextTranslation(choice.id).isEmpty)
              autoMove = Timer(
                Duration(milliseconds: 250),
                () => advanceStory(choice),
              );
          }
          return Column(
            children: [
              Text(getTextTranslation(currentNode.id)),
              if (choices != null && autoMove == null)
                for (final choice in choices)
                  TextButton(
                    onPressed: () => advanceStory(choice),
                    child: Text(getTextTranslation(choice.id)),
                  ),
              Divider(height: 0),
            ],
          );
        })
      ],
    );
  }
}
