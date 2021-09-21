import 'package:andax/content_loader.dart';
import 'package:andax/main.dart';
import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/translation_set.dart';
import 'package:andax/sample_scenario.dart';
import 'package:andax/screens/editor_screen.dart';
import 'package:andax/screens/play_screen.dart';
import 'package:andax/screens/scenario_info.dart';
import 'package:andax/screens/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/scenario.dart';
import 'crowdsourcing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController refreshController = RefreshController(
    initialRefresh: true,
  );
  List<ScenarioInfo> scenarios = [];

  void refreshScenarios() async {
    final scenarios = await algolia.instance
        .index('scenarios')
        .query('')
        // .filters('language:${settings.targetLanguage}')
        .getObjects()
        .then(
          (s) => s.hits.map(
            (h) => ScenarioInfo.fromAlgoliaHit(h),
          ),
        );
    setState(
      () => this.scenarios
        ..clear()
        ..addAll(scenarios),
    );
    refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scenarios'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(),
              ),
            ),
            icon: Icon(Icons.settings_outlined),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SmartRefresher(
              header: const MaterialClassicHeader(
                color: Colors.blue,
              ),
              controller: refreshController,
              onRefresh: refreshScenarios,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 76),
                children: [
                  for (final info in scenarios)
                    ListTile(
                      title: Text(info.title),
                      subtitle: info.description == null
                          ? null
                          : Text(info.description!),
                      onTap: () async {
                        final scenario = await loadScenario(info);
                        final translations = await loadTranslations(info);
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
                      trailing: IconButton(
                        icon: Icon(Icons.edit_outlined),
                        onPressed: () async {
                          final translations = await loadTranslations(info);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CrowdsourcingScreen(
                                scenarioId: info.scenarioID,
                                translations: translations,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.add_outlined),
      //   onPressed: () async {
      //     var path = await FirebaseFirestore.instance
      //         .collection('scenarios')
      //         .add(testScenario.toJson())
      //         .then((d) => d.path);

      //     path = await FirebaseFirestore.instance
      //         .collection('$path/translations')
      //         .add(
      //           TranslationSet(
      //             language: 'russian',
      //             metaData: ContentMetaData(''),
      //           ).toJson(),
      //         )
      //         .then((d) => d.path);

      //     final batch = FirebaseFirestore.instance.batch();

      //     for (final t in testTranslationsRu)
      //       batch.set(
      //         FirebaseFirestore.instance.doc('$path/assets/${t.metaData.id}'),
      //         t.toJson(),
      //       );
      //     await batch.commit();
      //     print('DONE');
      //   },
      // ),
    );
  }
}
