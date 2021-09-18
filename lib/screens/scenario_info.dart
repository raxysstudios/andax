import 'package:andax/screens/play_screen.dart';
import 'package:flutter/material.dart';
import 'package:andax/models/scenario.dart';

class ScenarioInfoScreen extends StatelessWidget {
  final ScenarioInfo scenarioInfo;

  const ScenarioInfoScreen({Key? key, required this.scenarioInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scenario')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(scenarioInfo.title),
          Text(scenarioInfo.description),
          ElevatedButton(
            onPressed: () {
              // Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => PlayScreen(scenario: scenario, translations: []),
              //           );
            },
            child: Text('Play'),
          ),
        ],
      ),
    );
  }
}
