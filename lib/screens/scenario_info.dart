import 'package:andax/sample_scenario.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/screens/crowdsourcing_screen.dart';
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
  bool loading = false;

  Future<void> loadScenario() async {
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
    final scenario = doc.data()!;

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
    final translations = await getTranslations();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayScreen(
          scenario: testScenario,
          translations: testTranslations,
        ),
      ),
    );
  }

  Future<List<TranslationAsset>> getTranslations() async {
    final collection = await FirebaseFirestore.instance
        .collection(
            'scenarios/${widget.scenarioInfo.scenarioID}/translations/${widget.scenarioInfo.translationID}/assets')
        .withConverter<TranslationAsset>(
          fromFirestore: (snapshot, _) =>
              TranslationAsset.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (scenario, _) => scenario.toJson(),
        )
        .get();
    final assets = collection.docs.map((doc) => doc.data());
    return assets.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scenarioInfo.title),
        actions: [
          IconButton(
            onPressed: () async {
              final translations = await getTranslations();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CrowdsourcingScreen(
                    scenarioId: widget.scenarioInfo.scenarioID,
                    translations: translations,
                  ),
                ),
              );
            },
            icon: Icon(Icons.edit_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          setState(() {
            loading = true;
          });
          await loadScenario();
          setState(() {
            loading = false;
          });
        },
        icon: loading
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : const Icon(Icons.play_arrow_outlined),
        label: loading ? const Text('Loading') : const Text('Play'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.scenarioInfo.description != null)
            Text(
              widget.scenarioInfo.description!,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }
}
