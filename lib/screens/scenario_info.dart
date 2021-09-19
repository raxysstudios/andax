import 'package:andax/models/translation_asset.dart';
import 'package:andax/screens/play_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:andax/models/scenario.dart';

class ScenarioInfoScreen extends StatefulWidget {
  final ScenarioInfo scenarioInfo;

  const ScenarioInfoScreen(this.scenarioInfo);

  @override
  State<ScenarioInfoScreen> createState() => _ScenarioInfoScreenState();
}

class _ScenarioInfoScreenState extends State<ScenarioInfoScreen> {
  late Scenario scenario;
  late List<TranslationAsset> translations;

  void getScenario() async {
    final db = FirebaseFirestore.instance;
    final doc = await db
        .doc('scenarios/${widget.scenarioInfo.scenarioID}')
        .withConverter<Scenario>(
          fromFirestore: (snapshot, _) =>
              Scenario.fromJson(snapshot.data()!, id: snapshot.id),
          toFirestore: (scenario, _) => scenario.toJson(),
        )
        .get();
    if (!doc.exists) {
      throw ArgumentError(
          'Scenario with id ${widget.scenarioInfo.scenarioID} does not exist');
    }
    scenario = doc.data()!;

    final collection = await db
        .collection(
            'scenarios/${widget.scenarioInfo.scenarioID}/translations/${widget.scenarioInfo.translationID}/assets')
        .withConverter<TranslationAsset>(
          fromFirestore: (snapshot, _) =>
              TranslationAsset.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (scenario, _) => scenario.toJson(),
        )
        .get();
    final assets = collection.docs.map((doc) => doc.data());
    translations = assets.toList();
  }

  @override
  void initState() {
    super.initState();
    getScenario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scenario')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(widget.scenarioInfo.title),
          if (widget.scenarioInfo.description != null)
            Text(widget.scenarioInfo.description!),
          ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayScreen(
                    scenario: scenario,
                    translations: translations,
                  ),
                ),
              );
            },
            child: Text('Play'),
          ),
        ],
      ),
    );
  }
}
