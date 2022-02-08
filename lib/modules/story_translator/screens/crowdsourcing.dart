import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
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
  final translations = <String, TranslationAsset>{};
  late final origins = <String, TranslationAsset>{
    for (final translation in widget.translations)
      translation.metaData.id: translation,
  };
  var language = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Story Translation'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showLoadingDialog(context, upload());
          Navigator.pop(context);
        },
        child: const Icon(Icons.upload_rounded),
        tooltip: 'Upload translation',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 76),
        children: [
          ...buildTranslatable(
            'language',
            language,
            icon: Icons.language_rounded,
            title: 'language',
            onEdit: (r) {
              language = r;
            },
          ),
          const Divider(height: 0),
          ...buildFields('story'),
          const Divider(height: 0),
          for (final a in origins.values.where(
            (w) => w.assetType == AssetType.actor,
          ))
            ...buildFields(a.metaData.id),
          const Divider(height: 0),
          for (final a in origins.values.where(
            (w) => w.assetType == AssetType.message,
          ))
            ...buildFields(a.metaData.id),
        ],
      ),
    );
  }

  List<Widget> buildTranslatable(
    String? origin,
    String? translation, {
    String? title,
    required IconData icon,
    required ValueSetter<String> onEdit,
  }) {
    if (origin?.isEmpty ?? true) return [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.caption,
            children: [
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    icon,
                    size: 16,
                  ),
                ),
              ),
              TextSpan(text: origin!),
            ],
          ),
        ),
      ),
      TextFormField(
        maxLines: null,
        initialValue: translation,
        decoration: InputDecoration(
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
        ),
        onChanged: (s) => onEdit(s),
      )
    ];
  }

  List<Widget> buildFields(String id) {
    final type = origins[id]!.assetType;
    switch (type) {
      case AssetType.message:
        final origin = origins[id] as MessageTranslation;
        final translation = translations[id] as MessageTranslation?;
        return buildTranslatable(
          origin.text,
          translation?.text,
          icon: Icons.notes_rounded,
          title: 'message',
          onEdit: (r) {
            translations[id] = MessageTranslation(
              id: id,
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
          icon: Icons.person_outline_rounded,
          title: 'actor',
          onEdit: (r) {
            translations[id] = ActorTranslation(
              id: id,
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
        return [
          ...buildTranslatable(
            origin.title,
            translation?.title,
            icon: Icons.title_rounded,
            title: 'story title',
            onEdit: (r) {
              translations[id] = StoryTranslation(
                id: id,
                title: r,
                description: translation?.description,
                tags: translation?.tags,
                metaData: ContentMetaData(
                    id, FirebaseAuth.instance.currentUser?.uid ?? ''),
              );
            },
          ),
          ...buildTranslatable(
            origin.description,
            translation?.description,
            icon: Icons.description_rounded,
            title: 'story description',
            onEdit: (r) {
              translations[id] = StoryTranslation(
                id: id,
                title: translation?.title ?? '<title>',
                description: r,
                tags: translation?.tags,
                metaData: ContentMetaData(id, ''),
              );
            },
          ),
          ...buildTranslatable(
            origin.tags?.join(' '),
            translation?.tags?.join(' '),
            icon: Icons.tag_rounded,
            title: 'story tags',
            onEdit: (r) {
              translations[id] = StoryTranslation(
                id: id,
                title: translation?.title ?? '<title>',
                description: translation?.description,
                tags: r.isEmpty
                    ? null
                    : r.split(' ').where((t) => t.isNotEmpty).toList(),
                metaData: ContentMetaData(id, ''),
              );
            },
          ),
        ];
      default:
        return [];
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
}
