import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/modules/editor/utils/editor_sheet.dart';
import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/asset.dart';

class TranslationEditorScreen extends StatefulWidget {
  const TranslationEditorScreen({
    required this.info,
    required this.narrative,
    required this.base,
    required this.target,
    Key? key,
  }) : super(key: key);

  final StoryInfo info;
  final Story narrative;
  final Translation base;
  final Translation target;

  @override
  State<TranslationEditorScreen> createState() => TranslationEditorState();
}

class TranslationEditorState extends State<TranslationEditorScreen> {
  StoryInfo get i => widget.info;
  Story get n => widget.narrative;
  Translation get b => widget.base;
  Translation get t => widget.target;

  late final Map<String, MapEntry<String, String>?> changes;
  late final bool exists;

  @override
  void initState() {
    super.initState();
    exists = t.language.isNotEmpty;
    changes = {for (final k in t.assets.keys) k: null};
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      child: Builder(
        builder: (context) {
          return WillPopScope(
            onWillPop: () => showDangerDialog(
              context,
              'Leave editor? Unsaved progress will be lost!',
              confirmText: 'Exit',
              rejectText: 'Stay',
            ),
            child: Scaffold(
              appBar: AppBar(
                leading: const RoundedBackButton(),
                title: const Text('Translations editor'),
              ),
              body: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: Text(t.language),
                  ),
                  buildExplanationTile(context, 'General info'),
                  const Asset('title', icon: Icons.title_rounded),
                  const Asset('description', icon: Icons.description_rounded),
                  const Asset('tags', icon: Icons.tag_rounded),
                  buildExplanationTile(context, 'Actors'),
                  for (final aid in n.actors.keys)
                    Asset(aid, icon: Icons.person_rounded),
                  buildExplanationTile(context, 'Cells'),
                  for (final cid in n.cells.entries
                      .where((e) => e.value.display != null)
                      .map((e) => e.key))
                    Asset(cid, icon: Icons.article_rounded)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
