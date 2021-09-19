import 'package:andax/widgets/add_new_node.dart';
import 'package:andax/widgets/node_preview.dart';
import 'package:andax/widgets/node_view.dart';
import 'package:flutter/material.dart';

class EditorScreen extends StatefulWidget {
  // final Scenario scenario;
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
        title: Text("Dialogue Editor"),
        // centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: () {
                print('saving...');
              },
              icon: Icon(
                Icons.save,
                size: 38.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(height: 16),
          AddNewNode(),
          NodePreview(text: "Hello my friend", id: 1),
          NodeView(),
        ],
      ),
    );
  }
}
