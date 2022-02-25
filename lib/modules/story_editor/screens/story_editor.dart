import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/modules/story_editor/screens/actors_editor.dart';
import 'package:andax/modules/story_editor/screens/info_editor.dart';
import 'package:andax/modules/story_editor/screens/narrative_editor.dart';
import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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
  late final Story story = widget.story ??
      Story(
        nodes: [],
        startNodeId: '',
        actors: [],
      );
  late final Translation translation = widget.translation ??
      Translation(
        language: '',
        assets: {
          'story': StoryTranslation(
            id: '',
            title: 'New story',
          )
        },
      );

  var _page = 0;
  final _paging = PageController();

  var done = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showDangerDialog(
        context,
        'Leave editor?' + (done ? '' : ' Unsaved progress will be lost!'),
        confirmText: 'Exit',
        rejectText: 'Stay',
      ).then((r) {
        done = false;
        return r;
      }),
      child: Scaffold(
        body: PageView(
          controller: _paging,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StoryInfoEditor(this),
            StoryNarrativeEditorScreen(this),
            StoryActorsEditorScreen(this),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
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
              icon: Icon(Icons.person_rounded),
              label: 'Actors',
            ),
          ],
          currentIndex: _page,
          onTap: (i) => setState(() {
            _page = i;
            _paging.animateToPage(
              i,
              duration: const Duration(milliseconds: 250),
              curve: standardEasing,
            );
          }),
        ),
      ),
    );
  }
}
