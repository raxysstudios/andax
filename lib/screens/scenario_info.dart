import 'package:andax/screens/play_screen.dart';
import 'package:flutter/material.dart';
import 'package:andax/models/scenario.dart';

class ScenarioInfoScreen extends StatelessWidget {
  final ScenarioInfo scenarioInfo;

  const ScenarioInfoScreen(this.scenarioInfo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scenario')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(scenarioInfo.title),
          if (scenarioInfo.description != null) Text(scenarioInfo.description!),
          ElevatedButton(
            onPressed: () async {
              print('SCNR TAP');
              // Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) => PlayScreen(scenario: scenario, translations: [,]),
              //           ),);
            },
            child: Text('Play'),
          ),
        ],
      ),
    );
  }
}
