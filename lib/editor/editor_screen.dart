// import 'package:andax/models/actor.dart';
// import 'package:andax/models/content_meta_data.dart';
// import 'package:andax/models/node.dart';
// import 'package:andax/models/scenario.dart';
// import 'package:andax/models/transition.dart';
// import 'package:andax/models/translation_asset.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';

// class EditorScreen extends StatefulWidget {
//   const EditorScreen({
//     Key? key,
//   }) : super(key: key);

//   @override
//   _EditorScreenState createState() => _EditorScreenState();
// }

// class _EditorScreenState extends State<EditorScreen>
//     with TickerProviderStateMixin {
//   final uuid = const Uuid();
//   final meta = ContentMetaData(
//     '',
//     FirebaseAuth.instance.currentUser?.uid ?? '',
//   );

//   late var scenario = Scenario(
//     nodes: {},
//     actors: {},
//     startNodeId: '',
//     metaData: meta,
//   );
//   late var translations = <String, TranslationAsset>{};

//   var language = "";
//   var tab = 0;
//   late var tabController = TabController(length: 3, vsync: this);

//   @override
//   void initState() {
//     super.initState();
//     tabController.animation?.addListener(() {
//       final tab = tabController.animation?.value.round() ?? 0;
//       if (this.tab != tab) {
//         setState(() {
//           this.tab = tab;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blueGrey.shade50,
//       floatingActionButton: Builder(
//         builder: (context) {
//           switch (tab) {
//             case 0:
//               return FloatingActionButton(
//                 onPressed: () {},
//                 child: const Icon(Icons.upload_outlined),
//               );
//             case 1:
//               return FloatingActionButton(
//                 onPressed: () => setState(
//                   () {
//                     final id = uuid.v4();
//                     scenario.actors[id] = Actor(id: id);
//                     translations[id] = ActorTranslation(metaData: meta);
//                   },
//                 ),
//                 child: const Icon(Icons.person_add_outlined),
//               );
//             case 2:
//               return FloatingActionButton(
//                 onPressed: () => setState(() {
//                   final id = uuid.v4();
//                   scenario.nodes[id] = Node(id);
//                   translations[id] = MessageTranslation(metaData: meta);
//                 }),
//                 child: const Icon(Icons.add_box_outlined),
//               );
//             default:
//               return const SizedBox();
//           }
//         },
//       ),
//       body: NestedScrollView(
//         headerSliverBuilder: (context, scrolled) {
//           return [
//             SliverOverlapAbsorber(
//               handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
//               sliver: SliverAppBar(
//                 title: const Text('Story Editor'),
//                 pinned: true,
//                 forceElevated: true,
//                 bottom: TabBar(
//                   controller: tabController,
//                   tabs: const [
//                     Tab(
//                       icon: Icon(Icons.auto_stories_outlined),
//                       text: "General",
//                     ),
//                     Tab(
//                       icon: Icon(Icons.person_outline),
//                       text: "Actors",
//                     ),
//                     Tab(
//                       icon: Icon(Icons.timeline_outlined),
//                       text: "Nodes",
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ];
//         },
//         body: TabBarView(
//           controller: tabController,
//           children: [
//             Builder(
//               builder: (context) {
//                 return CustomScrollView(
//                   key: const PageStorageKey('general'),
//                   slivers: [
//                     SliverOverlapInjector(
//                       handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
//                         context,
//                       ),
//                     ),
//                     SliverList(
//                       delegate: SliverChildListDelegate(
//                         [
//                           ListTile(
//                             leading: const Icon(Icons.language_outlined),
//                             title: TextFormField(
//                               decoration: const InputDecoration(
//                                 labelText: 'Initial language',
//                               ),
//                               initialValue: language,
//                               onChanged: (s) => setState(() {
//                                 language = s;
//                               }),
//                             ),
//                           ),
//                           ListTile(
//                             leading: const Icon(Icons.title_outlined),
//                             title: TextFormField(
//                               decoration: const InputDecoration(
//                                 labelText: 'Story title',
//                               ),
//                               initialValue:
//                                   ScenarioTranslation.get(translations)?.title,
//                               onChanged: (s) => setState(() {
//                                 final t = translations['scenario']
//                                     as ScenarioTranslation?;
//                                 if (t != null) t.title = s;
//                               }),
//                             ),
//                           ),
//                           ListTile(
//                             leading: const Icon(Icons.description_outlined),
//                             title: TextFormField(
//                               decoration: const InputDecoration(
//                                 labelText: 'Story description',
//                               ),
//                               initialValue:
//                                   ScenarioTranslation.get(translations)
//                                       ?.description,
//                               onChanged: (s) => setState(() {
//                                 final t = translations['scenario']
//                                     as ScenarioTranslation?;
//                                 if (t != null) t.description = s;
//                               }),
//                             ),
//                           ),
//                           ListTile(
//                             leading: const Icon(Icons.login_outlined),
//                             title: buildNodeSelector(
//                               context,
//                               scenario.nodes[scenario.startNodeId],
//                               (node) => setState(() {
//                                 scenario.startNodeId = node?.id ?? '';
//                               }),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//             Builder(
//               builder: (context) {
//                 return CustomScrollView(
//                   key: PageStorageKey('actors'),
//                   slivers: [
//                     SliverOverlapInjector(
//                       handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
//                         context,
//                       ),
//                     ),
//                     SliverList(
//                       delegate: SliverChildBuilderDelegate(
//                         (context, index) {
//                           final actor = scenario.actors[index];
//                           if (actor == null) return const SizedBox();
//                           return ListTile(
//                             leading: IconButton(
//                               onPressed: () => setState(() => actor.type =
//                                   actor.type == ActorType.npc
//                                       ? ActorType.player
//                                       : ActorType.npc),
//                               icon: Icon(actor.type == ActorType.npc
//                                   ? Icons.smart_toy_outlined
//                                   : Icons.face_outlined),
//                             ),
//                             title: TextFormField(
//                               decoration: const InputDecoration(
//                                 labelText: 'Actor name',
//                               ),
//                               initialValue:
//                                   (translations[actor.id] as ActorTranslation?)
//                                       ?.name,
//                               onChanged: (s) => setState(() {
//                                 final t =
//                                     translations[actor.id] as ActorTranslation?;
//                                 if (t != null) t.name = s;
//                               }),
//                             ),
//                             trailing: IconButton(
//                               onPressed: () => setState(() {
//                                 scenario.actors.remove(actor);
//                                 translations.remove(actor.id);
//                               }),
//                               icon: const Icon(Icons.delete_outline),
//                             ),
//                           );
//                         },
//                         childCount: scenario.actors.length,
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//             Builder(
//               builder: (context) {
//                 return CustomScrollView(
//                   key: const PageStorageKey('nodes'),
//                   slivers: [
//                     SliverOverlapInjector(
//                       handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
//                         context,
//                       ),
//                     ),
//                     SliverList(
//                       delegate: SliverChildBuilderDelegate(
//                         (context, index) {
//                           final node = scenario.nodes[index];
//                           if (node != null) {
//                             return Card(
//                               elevation: 0,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                                 children: [
//                                   ListTile(
//                                     leading: const Icon(Icons.person_outline),
//                                     title: DropdownButton(
//                                       icon: const SizedBox(),
//                                       underline: const SizedBox(),
//                                       value: (() {
//                                         for (final actor
//                                             in scenario.actors.values) {
//                                           if (actor.id == node.actorId) {
//                                             return actor;
//                                           }
//                                         }
//                                       })(),
//                                       onChanged: (Actor? actor) => setState(() {
//                                         node.actorId = actor?.id;
//                                       }),
//                                       items: [
//                                         const DropdownMenuItem<Actor>(
//                                           child: Text("None"),
//                                         ),
//                                         for (final actor
//                                             in scenario.actors.values)
//                                           DropdownMenuItem(
//                                             value: actor,
//                                             child: Text(
//                                               actor.getName(translations),
//                                             ),
//                                           )
//                                       ],
//                                     ),
//                                   ),
//                                   ListTile(
//                                     leading: const Icon(Icons.notes_outlined),
//                                     title: TextFormField(
//                                       maxLines: null,
//                                       initialValue: MessageTranslation.get(
//                                         translations,
//                                         node.id,
//                                       )?.text,
//                                       onChanged: (s) => setState(() {
//                                         final t = translations[node.id]
//                                             as MessageTranslation?;
//                                         if (t != null) t.text = s;
//                                       }),
//                                     ),
//                                   ),
//                                   const Divider(),
//                                   SwitchListTile(
//                                     value: node.autoTransition,
//                                     title: const Text('Auto transition'),
//                                     onChanged: (v) => setState(() {
//                                       node.autoTransition = v;
//                                     }),
//                                   ),
//                                   for (Transition transition
//                                       in node.transitions ?? [])
//                                     ListTile(
//                                       title: buildNodeSelector(
//                                         context,
//                                         scenario.nodes[transition.targetNodeId],
//                                         ((node) {
//                                           if (node != null) {
//                                             setState(
//                                               () {
//                                                 transition.targetNodeId =
//                                                     node.id;
//                                               },
//                                             );
//                                           }
//                                         }),
//                                         false,
//                                       ),
//                                       trailing: IconButton(
//                                         onPressed: () => setState(() => node
//                                             .transitions
//                                             ?.remove(transition)),
//                                         icon: const Icon(Icons.remove_outlined),
//                                       ),
//                                     ),
//                                   OutlinedButton.icon(
//                                     onPressed: () => setState(() {
//                                       final id = uuid.v4();
//                                       node.transitions ??= [];
//                                       node.transitions!.add(Transition(id,
//                                           targetNodeId: node.id));
//                                       translations[id] =
//                                           MessageTranslation(metaData: meta);
//                                     }),
//                                     icon: const Icon(Icons.alt_route_outlined),
//                                     label: const Text('Add Transition'),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }
//                         },
//                         childCount: scenario.nodes.length,
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
