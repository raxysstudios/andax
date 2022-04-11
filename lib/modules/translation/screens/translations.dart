import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/modules/translation/screens/translation_editor.dart';
import 'package:andax/modules/translation/services/translations.dart';
import 'package:andax/shared/services/story_loader.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/snackbar_manager.dart';
import 'package:flutter/material.dart';

class TranslationsScreen extends StatefulWidget {
  const TranslationsScreen({
    required this.info,
    Key? key,
  }) : super(key: key);

  final StoryInfo info;

  @override
  State<TranslationsScreen> createState() => _TranslationsScreenState();
}

class _TranslationsScreenState extends State<TranslationsScreen> {
  List<StoryInfo>? stories;
  late StoryInfo base;
  StoryInfo? target;

  @override
  void initState() {
    super.initState();
    getAllTranslations(widget.info.storyID).then(
      (s) => setState(() {
        stories = s;
        base = s.first;
      }),
    );
  }

  void previewTranslation(StoryInfo info) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(info.title),
          content: info.description.isEmpty ? null : Text(info.description),
          actions: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  base = info;
                  if (target == info) target = null;
                });
                Navigator.pop(context);
              },
              icon: const Icon(Icons.source_rounded),
              label: const Text('As base'),
            ),
            TextButton.icon(
              onPressed: () {
                if (info == base) {
                  showSnackbar(
                    context,
                    Icons.warning_rounded,
                    'Aready set as base',
                  );
                } else {
                  setState(() => target = info);
                }
                Navigator.pop(context);
              },
              icon: const Icon(Icons.translate_rounded),
              label: const Text('As target'),
            ),
          ],
        );
      },
    );
  }

  void openEditor() async {
    late final Story narrative;
    late final Translation base;
    late final Translation target;
    await showLoadingDialog(
      context,
      (() async {
        narrative = await loadNarrative(this.base);
        base = await loadTranslation(this.base);
        target = this.target == null
            ? Translation()
            : await loadTranslation(this.target!);
      })(),
    );
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return TranslationEditorScreen(
            info: widget.info,
            narrative: narrative,
            base: base,
            target: target,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Select trasnlations'),
      ),
      floatingActionButton: stories == null
          ? null
          : FloatingActionButton.extended(
              onPressed: openEditor,
              icon: Icon(
                target == null
                    ? Icons.note_add_rounded
                    : Icons.edit_note_rounded,
              ),
              label: Text(
                target == null ? 'Add translation' : 'Edit trasnlation',
              ),
            ),
      body: ListView(
        children: [
          if (stories == null)
            const ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Look for translations'),
              subtitle: Text('Please, wait...'),
            )
          else ...[
            for (final s in stories!)
              ListTile(
                leading: s == base
                    ? const Icon(Icons.source_rounded)
                    : s == target
                        ? const Icon(Icons.translate_rounded)
                        : null,
                title: Text(s.title),
                subtitle: s.description.isEmpty
                    ? null
                    : Text(
                        s.description,
                        maxLines: 1,
                      ),
                onTap: () => previewTranslation(s),
              )
          ]
        ],
      ),
    );
  }
}
