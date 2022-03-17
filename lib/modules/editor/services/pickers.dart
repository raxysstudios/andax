import 'package:andax/models/actor.dart';
import 'package:andax/models/cell.dart';
import 'package:andax/models/node.dart';
import 'package:andax/modules/editor/screens/actors.dart';
import 'package:andax/modules/editor/screens/cells.dart';
import 'package:andax/shared/widgets/scrollable_modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../screens/narrative.dart';
import '../screens/story.dart';

Future<Actor?> pickActor(BuildContext context, [Node? node]) {
  final editor = context.read<StoryEditorState>();
  return showScrollableModalSheet<Actor>(
    context: context,
    builder: (context, scroll) {
      return Provider.value(
        value: editor,
        child: Builder(
          builder: (context) {
            return ActorsEditorScreen(
              (a, _) => Navigator.pop(context, a),
              scroll: scroll,
              allowNone: true,
              selectedId: node?.actorId,
            );
          },
        ),
      );
    },
  );
}

Future<Node?> pickNode(BuildContext context, [Node? node]) {
  final editor = context.read<StoryEditorState>();
  return showScrollableModalSheet<Node>(
    context: context,
    builder: (context, scroll) {
      return Provider.value(
        value: editor,
        child: Builder(
          builder: (context) {
            return NarrativeEditorScreen(
              (n, _) => Navigator.pop(context, n),
              scroll: scroll,
              selectedId: node?.id,
            );
          },
        ),
      );
    },
  );
}

Future<Cell?> pickCell(BuildContext context, [Cell? cell]) {
  final editor = context.read<StoryEditorState>();
  return showScrollableModalSheet<Cell>(
    context: context,
    builder: (context, scroll) {
      return Provider.value(
        value: editor,
        child: Builder(
          builder: (context) {
            return CellsEditorScreen(
              (n, _) => Navigator.pop(context, n),
              scroll: scroll,
              selectedId: cell?.id,
            );
          },
        ),
      );
    },
  );
}
