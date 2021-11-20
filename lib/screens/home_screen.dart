import 'package:andax/editor/story_editor_screen.dart';
import 'package:andax/main.dart';
import 'package:andax/screens/scenario_info.dart';
import 'package:andax/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/scenario.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController refreshController = RefreshController(
    initialRefresh: true,
  );
  List<ScenarioInfo> scenarios = [];

  Future<void> refreshScenarios() async {
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
        title: const Text('Scenarios'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StoryEditorScreen(),
              ),
            ),
            icon: const Icon(Icons.construction_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            ),
            icon: const Icon(Icons.settings_outlined),
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
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ScenarioInfoScreen(info),
                          ),
                        );
                        await refreshScenarios();
                        refreshController.refreshCompleted();
                        setState(() {});
                      },
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
