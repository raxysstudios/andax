import 'dart:async';
import 'dart:math';

import 'package:andax/models/actor.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/transition.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/store_play/widgets/happiness_slider.dart';
import 'package:andax/modules/store_play/widgets/node_card.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

import '../utils/get_translation.dart';

class PlayScreen extends StatefulWidget {
  final Story story;
  final List<TranslationAsset> translations;

  const PlayScreen({
    required this.story,
    required this.translations,
    Key? key,
  }) : super(key: key);

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final Map<String, TranslationAsset> translations;
  Map<String, Node> get nodes => widget.story.nodes;
  Map<String, Actor> get actors => widget.story.actors;
  late Node currentNode;
  final List<Node> storyline = [];
  int totalScore = 50;

  Timer? autoAdvance;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    translations = {
      for (final translation in widget.translations)
        translation.metaData.id: translation,
    };
    currentNode = nodes[widget.story.startNodeId]!;

    if (currentNode.autoTransition && currentNode.transitions != null) {
      moveAuto(currentNode.transitions!);
    }
  }

  void advanceStory(Transition transition) {
    setState(() {
      autoAdvance?.cancel();
      storyline.add(currentNode);
      totalScore = max(0, min(totalScore + transition.score, 100));
      currentNode = nodes[transition.targetNodeId]!;
      isFinished =
          totalScore == 0 || (currentNode.transitions?.isEmpty ?? true);
      if (currentNode.autoTransition && currentNode.transitions != null) {
        moveAuto(currentNode.transitions!);
      }
    });
  }

  void moveAuto(List<Transition> transition) {
    autoAdvance?.cancel();
    autoAdvance = Timer(
      const Duration(milliseconds: 500),
      () {
        final index = Random().nextInt(transition.length);
        advanceStory(transition[index]);
        autoAdvance = null;
      },
    );
  }

  Widget fadeOut(Widget child) {
    return PlayAnimation<double>(
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      duration: const Duration(milliseconds: 300),
      child: child,
      builder: (context, child, value) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: HappinessSlider(value: totalScore),
        titleSpacing: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                totalScore.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 76),
        children: [
          for (var i = 0; i < storyline.length; i++)
            NodeCard(
              node: storyline[i],
              previousNode: i > 0 ? storyline[i - 1] : null,
              translations: translations,
              actors: actors,
            ),
          fadeOut(NodeCard(
            node: currentNode,
            previousNode: storyline.isEmpty ? null : storyline.last,
            translations: translations,
            actors: actors,
          )),
          if (currentNode.transitions != null &&
              !currentNode.autoTransition &&
              autoAdvance == null)
            fadeOut(Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final transition in currentNode.transitions!)
                    ElevatedButton(
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
            )),
          if (isFinished)
            fadeOut(const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'End',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )),
        ],
      ),
    );
  }
}
