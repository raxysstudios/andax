import 'package:andax/content_loader.dart';
import 'package:andax/editor/story_editor_screen.dart';
import 'package:andax/models/translation.dart';
import 'package:andax/screens/crowdsourcing_screen.dart';
import 'package:andax/screens/play_screen.dart';
import 'package:andax/widgets/loading_dialog.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:andax/models/story.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen(
    this.info, {
    Key? key,
  }) : super(key: key);

  final StoryInfo info;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: Text(widget.info.title),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 76),
        children: [
          if (widget.info.description != null)
            ListTile(
              leading: const Icon(Icons.info_rounded),
              title: Text(
                widget.info.description!,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final data = await showLoadingDialog<List>(
            context,
            Future.wait([
              loadStory(widget.info),
              loadTranslation(widget.info),
            ]),
          );
          if (data != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return PlayScreen(
                    story: data[0],
                    translations:
                        (data[1] as Translation).assets.values.toList(),
                  );
                },
              ),
            );
          }
        },
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Play'),
      ),
      floatingActionButtonLocation: FirebaseAuth.instance.currentUser == null
          ? null
          : FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: FirebaseAuth.instance.currentUser == null
          ? null
          : BottomAppBar(
              child: SizedBox(
                height: kBottomNavigationBarHeight + 27,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Contributing',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            final translation = await showLoadingDialog(
                              context,
                              loadTranslation(widget.info),
                            );
                            if (translation != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CrowdsourcingScreen(
                                    storyId: widget.info.storyID,
                                    translations:
                                        translation.assets.values.toList(),
                                  ),
                                ),
                              );
                            }
                          },
                          tooltip: 'Translate story',
                          icon: const Icon(Icons.translate_rounded),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            final data = await showLoadingDialog<List>(
                              context,
                              Future.wait([
                                loadStory(widget.info),
                                loadTranslation(widget.info),
                              ]),
                            );
                            if (data != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return StoryEditorScreen(
                                      story: data[0],
                                      translation: data[1] as Translation,
                                      info: widget.info,
                                    );
                                  },
                                ),
                              );
                            }
                          },
                          tooltip: 'Edit story',
                          icon: const Icon(Icons.edit_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
