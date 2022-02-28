import 'package:andax/models/story.dart';
import 'package:andax/modules/store_play/screens/play.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:andax/modules/story_translator/screens/crowdsourcing.dart';
import 'package:andax/shared/services/likes.dart';
import 'package:andax/shared/services/story_loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'loading_dialog.dart';
import 'modal_scrollable_sheet.dart';

Future<void> showStorySheet(BuildContext context, StoryInfo info) async {
  late bool liked;
  final likeService = LikeService(info);
  await likeService.updateLikedState().then((l) {
    liked = l ?? false;
  });
  await showModalScrollableSheet<void>(
    context: context,
    minSize: .6,
    builder: (context, scroll) {
      return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            FirebaseFirestore.instance
                .doc(
              'stories/${info.storyID}/translations/${info.translationID}',
            )
                .update({'metaData.views': FieldValue.increment(1)});
            await loadStory(
              context,
              info,
              (s, t) => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return PlayScreen(
                      story: s,
                      translation: t,
                    );
                  },
                ),
              ),
            );
          },
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Play'),
        ),
        body: CustomScrollView(
          controller: scroll,
          slivers: [
            SliverAppBar(
              title: Text(info.title),
              actions: [
                IconButton(
                  onPressed: () async {
                    final t = await showLoadingDialog(
                      context,
                      loadTranslation(info),
                    );
                    if (t != null) {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return CrowdsourcingScreen(
                              storyId: info.storyID,
                              translations: t.assets.values.toList(),
                            );
                          },
                        ),
                      );
                    }
                  },
                  tooltip: 'Translate story',
                  icon: const Icon(Icons.translate_rounded),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => loadStory(
                    context,
                    info,
                    (s, t) => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return StoryEditorScreen(
                            story: s,
                            translation: t,
                            info: info,
                          );
                        },
                      ),
                    ),
                  ),
                  tooltip: 'Edit story',
                  icon: const Icon(Icons.edit_rounded),
                ),
                const SizedBox(width: 8),
                StatefulBuilder(
                  builder: (context, setState) {
                    return IconButton(
                      onPressed: () => setState(() {
                        liked = !liked;
                        likeService.toggleLike(liked);
                      }),
                      icon: Icon(
                        liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  if (info.description != null)
                    ListTile(
                      leading: const Icon(Icons.info_rounded),
                      title: Text(
                        info.description!,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
