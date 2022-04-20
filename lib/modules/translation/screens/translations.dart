import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/modules/translation/screens/translation_editor.dart';
import 'package:andax/modules/translation/services/translations.dart';
import 'package:andax/modules/translation/widgets/translation_creator.dart';
import 'package:andax/shared/services/story_loader.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
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
  List<StoryInfo>? translations;
  late StoryInfo base;
  late StoryInfo target;

  @override
  void initState() {
    super.initState();
    getAllTranslations(widget.info.storyID).then(
      (s) => setState(() {
        translations = s;
        base = s.first;
        target = base;
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
                setState(() => base = info);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.source_rounded),
              label: const Text('As base'),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() => target = info);
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

  Future<void> openEditor() async {
    late final Story narrative;
    late final Translation base;
    late final Translation target;
    await showLoadingDialog(
      context,
      (() async {
        narrative = await loadNarrative(this.base);
        base = await loadTranslation(this.base);
        target = await loadTranslation(this.target);
      })(),
    );
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return TranslationEditorScreen(
            info: this.target,
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
        actions: [
          if (translations != null)
            IconButton(
              icon: const Icon(Icons.note_add_rounded),
              onPressed: () async {
                final data = await showTranslationCreator(context);
                if (data != null) {
                  final info = await showLoadingDialog(
                    context,
                    createTranslation(
                      context,
                      widget.info,
                      data.key,
                      data.value,
                    ),
                  );
                  if (info != null) {
                    target = info;
                    await openEditor();
                    Navigator.pop(context);
                  }
                }
              },
            ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: translations == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await openEditor();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Edit translation'),
            ),
      body: ListView(
        children: [
          if (translations == null)
            const ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Look for translations'),
              subtitle: Text('Please, wait...'),
            )
          else ...[
            for (final s in translations!)
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
