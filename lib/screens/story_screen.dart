import 'package:andax/models/translation_asset.dart';
import 'package:andax/screens/crowdsourcing_screen.dart';
import 'package:andax/screens/play_screen.dart';
import 'package:andax/widgets/loading_dialog.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:andax/models/story.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen(
    this.info, {
    Key? key,
  }) : super(key: key);

  final StoryInfo info;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  Future<void> loadScenario() async {
    final db = FirebaseFirestore.instance;
    final doc = await db
        .doc('scenarios/${widget.info.scenarioID}')
        .withConverter<Story>(
          fromFirestore: (snapshot, _) =>
              Story.fromJson(snapshot.data()!, id: snapshot.id),
          toFirestore: (scenario, _) => scenario.toJson(),
        )
        .get();
    if (!doc.exists) {
      throw ArgumentError(
          'Scenario with id ${widget.info.scenarioID} does not exist');
    }
    final scenario = doc.data()!;
    final translations = await getTranslations();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayScreen(
          scenario: scenario,
          translations: translations,
        ),
      ),
    );
  }

  Future<List<TranslationAsset>> getTranslations() async {
    final collection = await FirebaseFirestore.instance
        .collection(
            'scenarios/${widget.info.scenarioID}/translations/${widget.info.translationID}/assets')
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
        leading: const RoundedBackButton(),
        title: Text(widget.info.title),
        actions: [
          IconButton(
            onPressed: () async {
              final translations = await getTranslations();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CrowdsourcingScreen(
                    scenarioId: widget.info.scenarioID,
                    translations: translations,
                  ),
                ),
              );
            },
            tooltip: 'Translate',
            icon: const Icon(Icons.translate_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 76),
        children: [
          if (widget.info.description != null)
            ListTile(
              leading: const Icon(Icons.info_rounded),
              title: Text(
                widget.info.description!,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showLoadingDialog(
          context,
          loadScenario(),
        ),
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Play'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: kBottomNavigationBarHeight + 27,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Contributing',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.translate_rounded),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
