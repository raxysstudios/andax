import 'package:andax/models/node.dart';
import 'package:andax/models/story.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/modules/translation/services/assets.dart';
import 'package:andax/shared/extensions.dart';
import 'package:andax/shared/widgets/column_card.dart';
import 'package:andax/shared/widgets/danger_dialog.dart';
import 'package:andax/shared/widgets/loading_dialog.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/play.dart';
import '../widgets/asset.dart';

typedef AssetOverwrite = MapEntry<String, String>;

class TranslationEditorScreen extends StatefulWidget {
  const TranslationEditorScreen({
    required this.info,
    required this.narrative,
    required this.base,
    required this.target,
    Key? key,
  }) : super(key: key);

  final StoryInfo info;
  final Story narrative;
  final Translation base;
  final Translation target;

  @override
  State<TranslationEditorScreen> createState() => TranslationEditorState();
}

class TranslationEditorState extends State<TranslationEditorScreen> {
  StoryInfo get info => widget.info;
  Story get narrative => widget.narrative;
  Translation get base => widget.base;
  Translation get target => widget.target;

  final changes = <String, AssetOverwrite>{};

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
              confirmIcon: Icons.close_rounded,
              rejectText: 'Stay',
            ),
            child: Scaffold(
              appBar: AppBar(
                leading: const RoundedBackButton(),
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Translations\n',
                        style: textTheme.headline6,
                      ),
                      TextSpan(
                        text: target.language.titleCase,
                        style: TextStyle(
                          color: textTheme.caption?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: changes.isNotEmpty &&
                      FirebaseAuth.instance.currentUser?.uid ==
                          info.translationAuthorID
                  ? FloatingActionButton(
                      onPressed: () async {
                        await showLoadingDialog(
                          context,
                          applyAssetChanges(info, changes),
                        );
                        if (await showDangerDialog(
                          context,
                          'Translation is uploaded!',
                          confirmText: 'Finish',
                          confirmIcon: Icons.done_all,
                          rejectText: 'Continue editing',
                        )) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Icon(Icons.upload_rounded),
                    )
                  : null,
              body: PageView(
                controller: _paging,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ListView(
                    padding: const EdgeInsets.only(bottom: 76),
                    children: [
                      ColumnCard(
                        title: 'Info',
                        children: [
                          Asset('title', icon: Icons.title_rounded),
                          Asset('description', icon: Icons.description_rounded),
                          Asset('tags', icon: Icons.tag_rounded),
                        ],
                      ),
                      if (narrative.actors.isNotEmpty)
                        ColumnCard(
                          title: 'Characters',
                          children: [
                            for (final aid in narrative.actors.keys)
                              Asset(aid, icon: Icons.person_rounded),
                          ],
                        ),
                      if (narrative.cells.isNotEmpty)
                        ColumnCard(
                          title: 'Cells',
                          children: [
                            for (final cid in narrative.cells.entries
                                .where((e) => e.value.display != null)
                                .map((e) => e.key))
                              Asset(cid, icon: Icons.article_rounded),
                          ],
                        ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.only(bottom: 76),
                    children: [
                      for (final n in narrative.nodes.values)
                        Builder(builder: (context) {
                          final hasText = base[n.id]?.isNotEmpty ?? false;
                          final hasAudio =
                              base[n.id + '_audio']?.isNotEmpty ?? false;
                          final selectable = n.input == NodeInputType.select;
                          if (!hasText && !selectable && !hasAudio) {
                            return const SizedBox();
                          }
                          return ColumnCard(
                            children: [
                              if (hasText)
                                Asset(n.id, icon: Icons.chat_bubble_rounded),
                              if (hasAudio)
                                Asset(n.id, icon: Icons.audiotrack_rounded),
                              if (selectable)
                                for (final t in n.transitions)
                                  Asset(t.id, icon: Icons.call_split_rounded),
                            ],
                          );
                        }),
                    ],
                  ),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                selectedItemColor: textTheme.bodyText1?.color,
                unselectedItemColor: textTheme.caption?.color,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.info_rounded),
                    label: 'General',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.message_rounded),
                    label: 'Messages',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.play_arrow_rounded),
                    label: 'Play',
                  ),
                ],
                currentIndex: _page,
                onTap: (i) {
                  if (i == 2) {
                    return playTranslation(
                      context,
                      narrative,
                      target,
                      changes,
                    );
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
