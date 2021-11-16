import 'package:andax/models/actor.dart';
import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/scenario.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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
  final uuid = Uuid();
  final meta = ContentMetaData(
    '',
    FirebaseAuth.instance.currentUser?.uid ?? '',
  );

  late var scenario = new Scenario(
    nodes: [],
    actors: [],
    startNodeId: '',
    metaData: meta,
  );
  late var translations = <String, TranslationAsset>{};

  var language = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: Text("Story Editor"),
      ),
      body: ListView(
        children: [
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.language_outlined),
            title: TextFormField(
              decoration: InputDecoration(
                labelText: 'Initial language',
              ),
              initialValue: language,
              onChanged: (s) => setState(() {
                language = s;
              }),
            ),
          ),
          ListTile(
            leading: Icon(Icons.auto_stories),
            title: TextFormField(
              decoration: InputDecoration(
                labelText: 'Story title',
              ),
              initialValue: scenario.getTitle(translations),
              onChanged: (s) => setState(() {
                final t = translations['scenario'] as ScenarioTranslation?;
                if (t != null) t.title = s;
              }),
            ),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined),
            title: TextFormField(
              decoration: InputDecoration(
                labelText: 'Story description',
              ),
              initialValue: scenario.getDescription(translations),
              onChanged: (s) => setState(() {
                final t = translations['scenario'] as ScenarioTranslation?;
                if (t != null) t.description = s;
              }),
            ),
          ),
          Divider(),
          for (final actor in scenario.actors)
            ListTile(
              leading: IconButton(
                onPressed: () => setState(() => actor.type =
                    actor.type == ActorType.npc
                        ? ActorType.player
                        : ActorType.npc),
                icon: Icon(actor.type == ActorType.npc
                    ? Icons.smart_toy_outlined
                    : Icons.face_outlined),
              ),
              title: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Actor name',
                ),
                initialValue:
                    (translations[actor.id] as ActorTranslation?)?.name,
                onChanged: (s) => setState(() {
                  final t = translations[actor.id] as ActorTranslation?;
                  if (t != null) t.name = s;
                }),
              ),
              trailing: IconButton(
                onPressed: () => setState(() {
                  scenario.actors.remove(actor);
                  translations.remove(actor.id);
                }),
                icon: Icon(Icons.delete_outline),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton.icon(
              onPressed: () => setState(
                () {
                  final id = uuid.v4();
                  scenario.actors.add(Actor(id: id));
                  translations[id] = ActorTranslation(metaData: meta);
                },
              ),
              icon: Icon(Icons.person_add_outlined),
              label: Text('Add Actor'),
            ),
          ),
          Divider(),
          for (final node in scenario.nodes)
            Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: Icon(Icons.person_outline),
                    title: DropdownButton(
                      icon: SizedBox(),
                      underline: SizedBox(),
                      value: (() {
                        for (final actor in scenario.actors)
                          if (actor.id == node.actorId) return actor;
                      })(),
                      onChanged: (Actor? actor) => setState(() {
                        node.actorId = actor?.id;
                      }),
                      items: [
                        DropdownMenuItem<Actor>(
                          child: Text("None"),
                        ),
                        ...scenario.actors.map((a) => DropdownMenuItem(
                              value: a,
                              child: Text(a.getName(translations)),
                            ))
                      ].toList(),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.notes_outlined),
                    title: TextFormField(
                      maxLines: null,
                      initialValue:
                          (translations[node.id] as MessageTranslation?)?.text,
                      onChanged: (s) => setState(() {
                        final t = translations[node.id] as MessageTranslation?;
                        if (t != null) t.text = s;
                      }),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton.icon(
              onPressed: () => setState(() {
                final id = uuid.v4();
                scenario.nodes.add(Node(id));
                translations[id] = MessageTranslation(metaData: meta);
              }),
              icon: Icon(Icons.add_box_outlined),
              label: Text('Add Node'),
            ),
          )
        ],
      ),
    );
  }
}
