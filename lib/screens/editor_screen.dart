import 'package:andax/screens/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../scenarios/data/scenario.dart';
import 'package:andax/scenarios/data/translation_asset.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EditorScreen extends StatefulWidget {
  //final Scenario scenario;
  // final List<TranslationAsset> translations;

  const EditorScreen(//{
      //required this.scenario,
      //required this.translations
      //}
      );

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(51, 51, 51, 100),
        title: Text(
          "Dialogue Editor",
          style: TextStyle(
              fontSize: 24, color: Color.fromRGBO(189, 189, 189, 100)),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {/* Write listener code here */},
          child: Icon(
            Icons.arrow_back_sharp,
            size: 38.0,
            color: Color.fromRGBO(189, 189, 189, 100),
          ),
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.save,
                  size: 38.0,
                  color: Color.fromRGBO(189, 189, 189, 100),
                ),
              )),
        ],
      ),
      body: ListView(),
    );
  }
}
