import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/translation_asset.dart';
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
  late final Map<String, TranslationAsset> translations;
  late final Map<String, TranslationAsset> origins;
  String language = '';

  @override
  void initState() {
    super.initState();
    origins = {
      for (final translation in widget.translations)
        translation.metaData.id: translation,
    };
    translations = {
      for (final translation in widget.translations)
        translation.metaData.id: TranslationAsset.fromJson(
          translation.toJson(),
          translation.metaData.id,
        ),
    };
  }

  List<Widget> buildFields(String id) {
    final type = origins[id]!.assetType;
    switch (type) {
      case AssetType.actor:
        final origin = origins[id] as ActorTranslation;
        return [
          Text('Actor'),
          TextFormField(
            initialValue: origin.name,
            readOnly: true,
          ),
          TextFormField(
            onChanged: (s) {
              translations[id] = ActorTranslation(
                name: s,
                metaData: ContentMetaData(
                  id: id,
                  lastUpdateAt: DateTime.fromMillisecondsSinceEpoch(1),
                ),
              );
            },
          ),
        ];
      case AssetType.message:
        final origin = origins[id] as MessageTranslation;
        return [
          Text('Node \ Transition'),
          TextFormField(
            initialValue: origin.text,
            readOnly: true,
          ),
          TextFormField(
            onChanged: (s) {
              translations[id] = MessageTranslation(
                text: s,
                metaData: ContentMetaData(
                  id: id,
                  lastUpdateAt: DateTime.fromMillisecondsSinceEpoch(1),
                ),
              );
            },
          ),
        ];
      case AssetType.scenario:
        final origin = origins[id] as ScenarioTranslation;
        return [
          Text('Title'),
          TextFormField(
            initialValue: origin.title,
            readOnly: true,
          ),
          TextFormField(
            onChanged: (s) {
              final translation = translations[id] as ScenarioTranslation;
              translations[id] = ScenarioTranslation(
                title: s,
                description: translation.description,
                metaData: ContentMetaData(
                  id: id,
                  lastUpdateAt: DateTime.fromMillisecondsSinceEpoch(1),
                ),
              );
            },
          ),
          Text('Description'),
          TextFormField(
            initialValue: origin.description,
            readOnly: true,
          ),
          TextFormField(
            onChanged: (s) {
              final translation = translations[id] as ScenarioTranslation;
              translations[id] = ScenarioTranslation(
                title: translation.title,
                description: s,
                metaData: ContentMetaData(
                  id: id,
                  lastUpdateAt: DateTime.fromMillisecondsSinceEpoch(1),
                ),
              );
            },
          ),
        ];
      default:
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.upload_outlined),
        label: Text("Upload"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Language'),
          TextFormField(
            onChanged: (s) {
              language = s;
            },
          ),
          for (final id in translations.keys)
            Card(
              child: Column(
                children: buildFields(id),
              ),
            ),
        ],
      ),
    );
  }
}
