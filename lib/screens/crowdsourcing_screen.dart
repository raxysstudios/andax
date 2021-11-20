import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/widgets/loading_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CrowdsourcingScreen extends StatefulWidget {
  const CrowdsourcingScreen({
    required this.storyId,
    required this.translations,
    Key? key,
  }) : super(key: key);

  final String storyId;
  final List<TranslationAsset> translations;

  @override
  _CrowdsourcingScreenState createState() => _CrowdsourcingScreenState();
}

class _CrowdsourcingScreenState extends State<CrowdsourcingScreen> {
  late Map<String, TranslationAsset> translations;
  late final Map<String, TranslationAsset> origins;
  String language = '';

  @override
  void initState() {
    super.initState();
    origins = {
      for (final translation in widget.translations)
        translation.metaData.id: translation,
    };
    populateTranslations();
  }

  void populateTranslations([List<TranslationAsset>? source]) {
    setState(() {
      language = '';
      if (source == null) {
        translations = {};
      } else {
        translations = {
          for (final translation in source)
            translation.metaData.id: TranslationAsset.fromJson(
              translation.toJson(),
              translation.metaData.id,
            ),
        };
      }
    });
  }

  Widget buildTranslatable(
    String? origin,
    String? translation, {
    String? title,
    required IconData icon,
    required ValueSetter<String> onEdit,
  }) {
    if (origin?.isEmpty ?? true) return const SizedBox();
    return ListTile(
      leading: Icon(icon),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            origin!,
            style: Theme.of(context).textTheme.caption,
          ),
          if (translation != null) Text(translation),
        ],
      ),
      onTap: () async {
        var result = '';
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Translate $title'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    origin,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Expanded(
                    child: TextFormField(
                      maxLines: null,
                      initialValue: translation,
                      onChanged: (s) {
                        result = s;
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('DONE'),
                ),
              ],
            );
          },
        );
        setState(() => onEdit(result));
      },
    );
  }

  Widget buildFields(String id) {
    final type = origins[id]!.assetType;
    switch (type) {
      case AssetType.message:
        final origin = origins[id] as MessageTranslation;
        final translation = translations[id] as MessageTranslation?;
        return buildTranslatable(
          origin.text,
          translation?.text,
          icon: Icons.notes_outlined,
          title: 'message',
          onEdit: (r) {
            translations[id] = MessageTranslation(
              text: r,
              metaData: ContentMetaData(id, ''),
            );
          },
        );
      case AssetType.actor:
        final origin = origins[id] as ActorTranslation;
        final translation = translations[id] as ActorTranslation?;
        return buildTranslatable(
          origin.name,
          translation?.name,
          icon: Icons.person_outline,
          title: 'actor',
          onEdit: (r) {
            translations[id] = ActorTranslation(
              name: r,
              metaData: ContentMetaData(
                id,
                FirebaseAuth.instance.currentUser?.uid ?? '',
              ),
            );
          },
        );
      case AssetType.story:
        final origin = origins[id] as StoryTranslation;
        final translation = translations[id] as StoryTranslation?;
        return Column(
          children: [
            buildTranslatable(
              origin.title,
              translation?.title,
              icon: Icons.title_outlined,
              title: 'story title',
              onEdit: (r) {
                translations[id] = StoryTranslation(
                  title: r,
                  description: translation?.description,
                  metaData: ContentMetaData(
                      id, FirebaseAuth.instance.currentUser?.uid ?? ''),
                );
              },
            ),
            buildTranslatable(
              origin.description,
              translation?.description,
              icon: Icons.description_outlined,
              title: 'story description',
              onEdit: (r) {
                translations[id] = StoryTranslation(
                  title: translation?.title ?? '<title>',
                  description: r,
                  metaData: ContentMetaData(id, ''),
                );
              },
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Future<void> upload() async {
    final path = await FirebaseFirestore.instance
        .collection('stories/${widget.storyId}/translations')
        .add(
          Translation(
            language: language,
            metaData: ContentMetaData(
              '',
              FirebaseAuth.instance.currentUser?.uid ?? '',
            ),
            assets: {},
          ).toJson(),
        )
        .then((d) => d.path);
    final batch = FirebaseFirestore.instance.batch();

    for (final t in translations.entries) {
      batch.set(
        FirebaseFirestore.instance.doc('$path/assets/${t.key}'),
        t.value.toJson(),
      );
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story translation'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showLoadingDialog(context, upload()),
        icon: const Icon(Icons.upload_outlined),
        label: const Text("Upload"),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 76),
        children: [
          buildTranslatable(
            'language',
            language,
            icon: Icons.language_outlined,
            title: 'language',
            onEdit: (r) {
              language = r;
            },
          ),
          const Divider(height: 0),
          buildFields('story'),
          const Divider(height: 0),
          for (final a in origins.values.where(
            (w) => w.assetType == AssetType.actor,
          ))
            buildFields(a.metaData.id),
          const Divider(height: 0),
          for (final a in origins.values.where(
            (w) => w.assetType == AssetType.message,
          ))
            buildFields(a.metaData.id),
        ],
      ),
    );
  }
}
