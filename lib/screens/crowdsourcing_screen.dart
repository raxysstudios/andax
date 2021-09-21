import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/models/translation_set.dart';
import 'package:andax/sample_scenario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CrowdsourcingScreen extends StatefulWidget {
  final String scenarioId;
  final List<TranslationAsset> translations;

  const CrowdsourcingScreen({
    required this.scenarioId,
    required this.translations,
  });

  @override
  _CrowdsourcingScreenState createState() => _CrowdsourcingScreenState();
}

class _CrowdsourcingScreenState extends State<CrowdsourcingScreen> {
  late Map<String, TranslationAsset> translations;
  late final Map<String, TranslationAsset> origins;
  String language = '';
  bool isLoading = false;

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
      } else
        translations = {
          for (final translation in source)
            translation.metaData.id: TranslationAsset.fromJson(
              translation.toJson(),
              translation.metaData.id,
            ),
        };
    });
  }

  Widget buildTranslatable(
    String? origin,
    String? translation, {
    String? title,
    required IconData icon,
    required ValueSetter<String> onEdit,
  }) {
    if (origin?.isEmpty ?? true) return SizedBox();
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
                  child: Text('DONE'),
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
              metaData: ContentMetaData(id),
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
              metaData: ContentMetaData(id),
            );
          },
        );
      case AssetType.scenario:
        final origin = origins[id] as ScenarioTranslation;
        final translation = translations[id] as ScenarioTranslation?;
        return Column(
          children: [
            buildTranslatable(
              origin.title,
              translation?.title,
              icon: Icons.title_outlined,
              title: 'scenario title',
              onEdit: (r) {
                translations[id] = ScenarioTranslation(
                  title: r,
                  description: translation?.description,
                  metaData: ContentMetaData(id),
                );
              },
            ),
            buildTranslatable(
              origin.description,
              translation?.description,
              icon: Icons.description_outlined,
              title: 'scenario description',
              onEdit: (r) {
                translations[id] = ScenarioTranslation(
                  title: translation?.title ?? '<title>',
                  description: r,
                  metaData: ContentMetaData(id),
                );
              },
            ),
          ],
        );
      default:
        return SizedBox();
    }
  }

  Future<void> uploadTranslation() async {
    final path = await FirebaseFirestore.instance
        .collection('scenarios/${widget.scenarioId}/translations')
        .add(
          TranslationSet(
            language: language,
            metaData: ContentMetaData(''),
          ).toJson(),
        )
        .then((d) => d.path);
    final batch = FirebaseFirestore.instance.batch();

    for (final t in translations.entries)
      batch.set(
        FirebaseFirestore.instance.doc('$path/assets/${t.key}'),
        t.value.toJson(),
      );
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scenarion translation'),
        actions: [
          IconButton(
            onPressed: () {
              print('tap');
              populateTranslations(presetScenario);
            },
            icon: Icon(Icons.translate_outlined),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading
            ? null
            : () async {
                setState(() {
                  isLoading = true;
                });
                await uploadTranslation();
                setState(() {
                  isLoading = false;
                });
              },
        icon: isLoading
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : Icon(Icons.upload_outlined),
        label: Text("Upload"),
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
          Divider(height: 0),
          buildFields('scenario'),
          Divider(height: 0),
          for (final a in origins.values.where(
            (w) => w.assetType == AssetType.actor,
          ))
            buildFields(a.metaData.id),
          Divider(height: 0),
          for (final a in origins.values.where(
            (w) => w.assetType == AssetType.message,
          ))
            buildFields(a.metaData.id),
        ],
      ),
    );
  }
}
