import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'data/scenario.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ScenariosScreen extends StatefulWidget {
  const ScenariosScreen();

  @override
  _ScenariosScreenState createState() => _ScenariosScreenState();
}

class _ScenariosScreenState extends State<ScenariosScreen> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );
  List<Scenario> _scenarios = [];

  Future<void> _refreshScenarios() async {
    _scenarios = await FirebaseFirestore.instance
        .collection('scenarios')
        .withConverter(
          fromFirestore: (snapshot, _) =>
              Scenario.fromJson(snapshot.data()!, id: snapshot.id),
          toFirestore: (Scenario object, _) => object.toJson(),
        )
        .get()
        .then((data) => data.docs.map((d) => d.data()).toList());
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scenarios'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SmartRefresher(
              header: MaterialClassicHeader(
                color: Colors.blue,
              ),
              controller: _refreshController,
              onRefresh: _refreshScenarios,
              child: ListView(
                children: [
                  for (final scenario in _scenarios)
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
                      // onTap: () => Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => PhraseListScreen(
                      //       chapter: c,
                      //     ),
                      //   ),
                      // ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
