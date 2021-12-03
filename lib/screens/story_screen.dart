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

class StoryScreen extends StatelessWidget {
  const StoryScreen(
    this.info, {
    Key? key,
  }) : super(key: key);

  final StoryInfo info;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: Text(info.title),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 76),
        children: [
          if (info.description != null)
            ListTile(
              leading: const Icon(Icons.info_rounded),
              title: Text(
                info.description!,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          late final Story story;
          late final Translation translation;
          await showLoadingDialog<void>(
            context,
            (() async {
              story = await loadStory(info);
              translation = await loadTranslation(info);
            })(),
          );
          await Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PlayScreen(
                  story: story,
                  translations: translation.assets.values.toList(),
                );
              },
            ),
          );
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
                              loadTranslation(info),
                            );
                            if (translation != null) {
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CrowdsourcingScreen(
                                    storyId: info.storyID,
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
                            late final Story story;
                            late final Translation translation;
                            await showLoadingDialog<void>(
                              context,
                              (() async {
                                story = await loadStory(info);
                                translation = await loadTranslation(info);
                              })(),
                            );
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return StoryEditorScreen(
                                    story: story,
                                    translation: translation,
                                    info: info,
                                  );
                                },
                              ),
                            );
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
