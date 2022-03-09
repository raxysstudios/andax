import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/editor/screens/cells.dart';
import 'package:andax/modules/editor/screens/node.dart';
import 'package:andax/modules/editor/widgets/cell_dialog.dart';
import 'package:andax/modules/play/screens/play.dart';
import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../widgets/actor_editor_dialog.dart';
import 'actors.dart';
import 'info.dart';
import 'narrative.dart';

class StoryEditorScreen extends StatefulWidget {
  const StoryEditorScreen({
    this.story,
    this.translation,
    this.info,
    Key? key,
  }) : super(key: key);

  final Story? story;
  final Translation? translation;
  final StoryInfo? info;

  @override
  StoryEditorState createState() => StoryEditorState();
}

class StoryEditorState extends State<StoryEditorScreen> {
  final uuid = const Uuid();

  late StoryInfo? info = widget.info;
  late final Story story = widget.story ?? Story();
  late final Translation translation = widget.translation ??
      Translation(
        language: '',
        assets: {
          'story': StoryTranslation(
            '',
            title: 'New story',
          )
        },
      );

  var _page = 0;
  final _paging = PageController();

  @override
  void setState(void Function() fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Provider.value(
      value: this,
      child: Builder(
        builder: (context) {
          return WillPopScope(
            onWillPop: () => showDangerDialog(
              context,
              'Leave editor? Unsaved progress will be lost!',
              confirmText: 'Exit',
              rejectText: 'Stay',
            ),
            child: Scaffold(
              body: PageView(
                controller: _paging,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // ignore: prefer_const_constructors
                  InfoEditorScreen(),
                  NarrativeEditorScreen(
                    (node, isNew) async {
                      if (!isNew) {
                        await openNodeEditor(context, node);
                      }
                      setState(() {});
                    },
                    allowInteractive: true,
                  ),
                  ActorsEditorScreen(
                    (actor, isNew) async {
                      if (!isNew) {
                        await showActorEditorDialog(
                          context,
                          actor,
                        );
                      }
                      setState(() {});
                    },
                  ),
                  CellsEditorScreen(
                    (cell, isNew) async {
                      if (!isNew) {
                        await showCellEditorDialog(
                          context,
                          cell,
                        );
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                selectedItemColor: textTheme.bodyText1?.color,
                unselectedItemColor: textTheme.caption?.color,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history_edu_rounded),
                    label: 'Info',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.insights_rounded),
                    label: 'Narrative',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.groups_rounded),
                    label: 'Actors',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inventory_2_rounded),
                    label: 'Cells',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.play_arrow_rounded),
                    label: 'Play',
                  ),
                ],
                currentIndex: _page,
                onTap: (i) {
                  if (i == 3) {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PlayScreen(
                            story: story,
                            translation: translation,
                          );
                        },
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _page = i;
                    _paging.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 250),
                      curve: standardEasing,
                    );
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
