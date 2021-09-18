import 'package:andax/screens/editor_screen.dart';
import 'package:andax/screens/scenario_info.dart';
import 'package:andax/screens/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/scenario.dart';
import '../store.dart';

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

  Future<ScenarioInfo> loadScenarioInfo(Scenario scenario) async {
    final id = scenario.metaData.id;
    print('Loading scenario info for $id');
    final assetsCollection = FirebaseFirestore.instance.collection(
        'scenarios/$id/translations/${settings.currentLanguage}/assets');
    final scenarioSnapshot = await assetsCollection
        .doc('scenario')
        .withConverter<ScenarioInfo>(
            fromFirestore: (snapshot, _) => ScenarioInfo(
                  id: snapshot.id,
                  title: snapshot.data()!['title'],
                  description: snapshot.data()!['description'],
                ),
            toFirestore: (item, _) => {
                  'title': item.title,
                  'description': item.description,
                })
        .get();
    if (!scenarioSnapshot.exists) {
      throw new ArgumentError('Scenario $id information not found');
    }
    return scenarioSnapshot.data()!;
  }

  Future<void> refreshScenarios() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('scenarios')
        .withConverter(
          fromFirestore: (snapshot, _) =>
              Scenario.fromJson(snapshot.data()!, id: snapshot.id),
          toFirestore: (Scenario object, _) => object.toJson(),
        )
        .get();
    print('Scenarios: ${snapshot.docs}');
    final data = snapshot.docs.map((d) => d.data());
    scenarios = await Future.wait(data.map(loadScenarioInfo));
    setState(() {});
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
              header: MaterialClassicHeader(
                color: Colors.blue,
              ),
              controller: refreshController,
              onRefresh: refreshScenarios,
              child: ListView(
                children: [
                  for (final scenario in scenarios)
                    ListTile(
                      title: Text(
                        scenario.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(scenario.description),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScenarioInfoScreen(
                            scenarioInfo: scenario,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_circle),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditorScreen(),
            ),
          );
        },
      ),
    );
  }
}
