import 'package:andax/models/node.dart';
import 'package:andax/modules/play/utils/animator.dart';
import 'package:andax/modules/play/widgets/actor_chip.dart';
import 'package:andax/modules/play/widgets/message_card.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/play.dart';
import '../utils/audio_controller.dart';

class NodeDisplay extends StatelessWidget {
  const NodeDisplay({
    Key? key,
    required this.node,
    required this.previousNode,
  }) : super(key: key);

  final Node node;
  final Node? previousNode;

  @override
  Widget build(BuildContext context) {
    final play = context.watch<PlayScreenState>();
    final actor = play.actors[node.actorId];
    final text = play.tr.node(node, allowEmpty: true);
    final aUrl = play.tr.audio(node);
    final audio = play.audio;
    if (text.isEmpty) return const SizedBox();

    final thread = actor?.id == previousNode?.actorId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (thread)
          const SizedBox(height: 2)
        else if (actor == null)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '• • •',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          const SizedBox(height: 16),
        if (node.image != null)
          Image.network(
            node.image!.url,
            height: node.image!.height,
            fit: node.image!.fit,
            alignment: node.image!.alignment,
          ),
        if (actor != null && !thread) ActorChip(actor),
        if (text.isNotEmpty)
          MessageCard(
            text,
            onTap: aUrl.isEmpty ? null : () => audio.play(aUrl, node.id),
          ),
        ChangeNotifierProvider.value(
          value: audio,
          builder: (context, _) {
            var v = 0;
            var drag = false;
            return StatefulBuilder(
              builder: (context, setState) {
                final audio = context.watch<AudioController>();
                if (!drag) v = audio.position;
                if (audio.key != node.id) return const SizedBox();
                return slideUp(
                  key: Key(audio.key),
                  child: Slider(
                    value: v.toDouble(),
                    max: audio.duration.toDouble(),
                    onChanged: (s) => setState(() {
                      drag = true;
                      v = s.toInt();
                    }),
                    onChangeEnd: (s) async {
                      await audio.seek(s.toInt());
                      setState(() {
                        drag = false;
                      });
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
