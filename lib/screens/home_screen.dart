import 'package:andax/main.dart';
import 'package:andax/screens/editor_screen.dart';
import 'package:andax/screens/scenario_info.dart';
import 'package:andax/screens/settings_screen.dart';
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

  void refreshScenarios() async {
    final scenarios = await algolia.instance
        .index('scenarios')
        .query('')
        .filters('language:${settings.targetLanguage}')
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
                      subtitle: scenario.description == null
                          ? null
                          : Text(scenario.description!),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScenarioInfoScreen(scenario),
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
        child: Icon(Icons.add_circle_outline),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditorScreen(),
          ),
        ),
      ),
    );
  }
}
