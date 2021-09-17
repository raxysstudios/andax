import 'package:andax/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'scenarios/data/scenario.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController refreshController = RefreshController(
    initialRefresh: true,
  );
  List<Scenario> scenarios = [];

  Future<void> refreshScenarios() async {
    scenarios = await FirebaseFirestore.instance
        .collection('scenarios')
        .withConverter(
          fromFirestore: (snapshot, _) =>
              Scenario.fromJson(snapshot.data()!, id: snapshot.id),
          toFirestore: (Scenario object, _) => object.toJson(),
        )
        .get()
        .then((data) => data.docs.map((d) => d.data()).toList());
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
              // child: ListView(
              //   children: [
              //     for (final scenario in _scenarios)
              //       ListTile(
              //         title: Text(
              //           scenario.title,
              //           style: TextStyle(
              //             fontSize: 18,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //         subtitle: scenario.description == null
              //             ? null
              //             : Text(scenario.description!),
              //         // onTap: () => Navigator.push(
              //         //   context,
              //         //   MaterialPageRoute(
              //         //     builder: (context) => PhraseListScreen(
              //         //       chapter: c,
              //         //     ),
              //         //   ),
              //         // ),
              //       )
              //   ],
              // ),
            ),
          ),
        ],
      ),
    );
  }
}
