import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/modules/editor/utils/editor_sheet.dart';
import 'package:andax/modules/translation/widgets/translation_asset.dart';
import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  State<TranslationEditorScreen> createState() =>
      TranslationEditorScreenState();
}

class TranslationEditorScreenState extends State<TranslationEditorScreen> {
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
                    title: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Language',
                      ),
                      initialValue: widget.target.language,
                      validator: emptyValidator,
                      onChanged: (s) => widget.target.language = s.trim(),
                    ),
                  ),
                  buildExplanationTile(context, 'General info'),
                  const TranslationAsset(
                    'title',
                    icon: Icons.title_rounded,
                    maxLines: null,
                  ),
                  const TranslationAsset(
                    'description',
                    icon: Icons.description_rounded,
                    maxLines: null,
                  ),
                  const TranslationAsset(
                    'tags',
                    icon: Icons.tag_rounded,
                  ),
                  buildExplanationTile(context, 'Actors'),
                  for (final aid in widget.narrative.actors.keys)
                    TranslationAsset(
                      aid,
                      icon: Icons.person_rounded,
                    ),
                  buildExplanationTile(context, 'Cells'),
                  for (final cid in widget.narrative.cells.entries
                      .where((e) => e.value.display != null)
                      .map((e) => e.key))
                    TranslationAsset(
                      cid,
                      icon: Icons.article_rounded,
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
