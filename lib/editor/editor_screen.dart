import 'package:andax/models/actor.dart';
import 'package:andax/models/content_meta_data.dart';
import 'package:andax/models/node.dart';
import 'package:andax/models/scenario.dart';
import 'package:andax/models/transition.dart';
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

class _EditorScreenState extends State<EditorScreen>
    with TickerProviderStateMixin {
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
  var tab = 0;
  late var tabController = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    tabController.animation?.addListener(() {
      final tab = tabController.animation?.value.round() ?? 0;
      if (this.tab != tab) {
        setState(() {
          this.tab = tab;
        });
      }
    });
  }

  Node? getNodeById(String? id) {
    for (final node in scenario.nodes)
      if (node.id == scenario.startNodeId) return node;
  }

  DropdownButton<Node> buildNodeSelector(
    BuildContext context,
    Node? value,
    ValueSetter<Node?> onChanged, [
    allowNone = true,
  ]) {
    return DropdownButton(
      icon: SizedBox(),
      underline: SizedBox(),
      value: value,
      onChanged: onChanged,
      items: [
        if (allowNone)
          DropdownMenuItem<Node>(
            child: Text("None"),
          ),
        ...scenario.nodes.map((n) => DropdownMenuItem(
              value: n,
              child: Text(
                (translations[n.id] as MessageTranslation?)?.text ?? '',
              ),
            ))
      ].toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      floatingActionButton: Builder(
        builder: (context) {
          switch (tab) {
            case 0:
              return FloatingActionButton(
                onPressed: () {},
                child: Icon(Icons.upload_outlined),
              );
            case 1:
              return FloatingActionButton(
                onPressed: () => setState(
                  () {
                    final id = uuid.v4();
                    scenario.actors.add(Actor(id: id));
                    translations[id] = ActorTranslation(metaData: meta);
                  },
                ),
                child: Icon(Icons.person_add_outlined),
              );
            case 2:
              return FloatingActionButton(
                onPressed: () => setState(() {
                  final id = uuid.v4();
                  scenario.nodes.add(Node(id));
                  translations[id] = MessageTranslation(metaData: meta);
                }),
                child: Icon(Icons.add_box_outlined),
              );
            default:
              return SizedBox();
          }
        },
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, scrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                title: const Text('Story Editor'),
                pinned: true,
                forceElevated: true,
                bottom: TabBar(
                  controller: tabController,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.auto_stories_outlined),
                      text: "General",
                    ),
                    Tab(
                      icon: Icon(Icons.person_outline),
                      text: "Actors",
                    ),
                    Tab(
                      icon: Icon(Icons.timeline_outlined),
                      text: "Nodes",
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: [
            Builder(
              builder: (context) {
                return CustomScrollView(
                  key: PageStorageKey('general'),
                  slivers: [
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
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
                            leading: Icon(Icons.title_outlined),
                            title: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Story title',
                              ),
                              initialValue: scenario.getTitle(translations),
                              onChanged: (s) => setState(() {
                                final t = translations['scenario']
                                    as ScenarioTranslation?;
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
                              initialValue:
                                  scenario.getDescription(translations),
                              onChanged: (s) => setState(() {
                                final t = translations['scenario']
                                    as ScenarioTranslation?;
                                if (t != null) t.description = s;
                              }),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.login_outlined),
                            title: buildNodeSelector(
                              context,
                              getNodeById(scenario.startNodeId),
                              (node) => setState(() {
                                scenario.startNodeId = node?.id ?? '';
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Builder(
              builder: (context) {
                return CustomScrollView(
                  key: PageStorageKey('actors'),
                  slivers: [
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final actor = scenario.actors[index];
                          return ListTile(
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
                                  (translations[actor.id] as ActorTranslation?)
                                      ?.name,
                              onChanged: (s) => setState(() {
                                final t =
                                    translations[actor.id] as ActorTranslation?;
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
                          );
                        },
                        childCount: scenario.actors.length,
                      ),
                    ),
                  ],
                );
              },
            ),
            Builder(
              builder: (context) {
                return CustomScrollView(
                  key: PageStorageKey('nodes'),
                  slivers: [
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final node = scenario.nodes[index];
                          return Card(
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
                                        if (actor.id == node.actorId)
                                          return actor;
                                    })(),
                                    onChanged: (Actor? actor) => setState(() {
                                      node.actorId = actor?.id;
                                    }),
                                    items: [
                                      DropdownMenuItem<Actor>(
                                        child: Text("None"),
                                      ),
                                      ...scenario.actors
                                          .map((a) => DropdownMenuItem(
                                                value: a,
                                                child: Text(
                                                    a.getName(translations)),
                                              ))
                                    ].toList(),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(Icons.notes_outlined),
                                  title: TextFormField(
                                    maxLines: null,
                                    initialValue: (translations[node.id]
                                            as MessageTranslation?)
                                        ?.text,
                                    onChanged: (s) => setState(() {
                                      final t = translations[node.id]
                                          as MessageTranslation?;
                                      if (t != null) t.text = s;
                                    }),
                                  ),
                                ),
                                Divider(),
                                for (Transition transition
                                    in node.transitions ?? [])
                                  ListTile(
                                    title: buildNodeSelector(
                                      context,
                                      getNodeById(transition.targetNodeId),
                                      (node) => setState(
                                        () {
                                          if (node != null)
                                            transition.targetNodeId = node.id;
                                        },
                                      ),
                                      false,
                                    ),
                                    trailing: IconButton(
                                      onPressed: () => setState(() =>
                                          node.transitions?.remove(transition)),
                                      icon: Icon(Icons.remove_outlined),
                                    ),
                                  ),
                                OutlinedButton.icon(
                                  onPressed: () => setState(() {
                                    final id = uuid.v4();
                                    if (node.transitions == null)
                                      node.transitions = [];
                                    node.transitions!.add(
                                        Transition(id, targetNodeId: node.id));
                                    translations[id] =
                                        MessageTranslation(metaData: meta);
                                  }),
                                  icon: Icon(
                                    Icons.alt_route_outlined,
                                  ),
                                  label: Text('Add Transition'),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: scenario.nodes.length,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
