import 'package:andax/models/story.dart';
import 'package:andax/modules/store_play/screens/play.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:andax/shared/services/likes.dart';
import 'package:andax/shared/services/story_loader.dart';
import 'package:andax/shared/utils.dart';
import 'package:andax/shared/widgets/gradient_cover_image.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/span_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'modal_scrollable_sheet.dart';

Future<void> showStorySheet(BuildContext context, StoryInfo info) async {
  late bool liked;
  final likeService = LikeService(info);
  await likeService.updateLikedState().then((l) {
    liked = l ?? false;
  });
  final textTheme = Theme.of(context).textTheme;
  final user = FirebaseAuth.instance.currentUser;
  await showModalScrollableSheet<void>(
    context: context,
    minSize: .6,
    builder: (context, scroll) {
      return Scaffold(
        appBar: AppBar(
          leading: const RoundedBackButton(),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight + 3),
            child: SizedBox(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: GradientCoverImage(
              info.imageUrl,
              opacity: .5,
              reversed: true,
              placeholderSize: 128,
            ),
          ),
          actions: [
            Chip(
              avatar: const Icon(Icons.visibility_rounded),
              label: Text(info.views.toString()),
            ),
            const SizedBox(width: 8),
            StatefulBuilder(
              builder: (context, setState) {
                final likes = info.likes + (liked ? 1 : 0);
                return InputChip(
                  avatar: Icon(
                    liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                  ),
                  label: Text(likes.toString()),
                  onPressed: () => setState(() {
                    liked = !liked;
                    likeService.toggleLike(liked);
                  }),
                );
              },
            ),
            const SizedBox(width: 8),
            PopupMenuButton<void>(itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: () {
                    // Should point to cloud function probably.
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.report_rounded),
                      SizedBox(width: 16),
                      Text('Report'),
                    ],
                  ),
                ),
                if (user != null) ...[
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    onTap: () async {
                      // Crowdsroucing is broken
                      // final t = await showLoadingDialog(
                      //   context,
                      //   loadTranslation(info),
                      // );
                      // if (t != null) {
                      //   Navigator.push<void>(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) {
                      //         return CrowdsourcingScreen(
                      //           storyId: info.storyID,
                      //           translations: t.assets.values.toList(),
                      //         );
                      //       },
                      //     ),
                      //   );
                      // }
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.translate_rounded),
                        SizedBox(width: 16),
                        Text('Add translation'),
                      ],
                    ),
                  ),
                  if (user.uid == info.storyAuthorID)
                    PopupMenuItem(
                      onTap: () => loadStory(
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
                      child: Row(
                        children: const [
                          Icon(Icons.edit_rounded),
                          SizedBox(width: 16),
                          Text('Edit story'),
                        ],
                      ),
                    ),
                ]
              ];
            }),
            const SizedBox(width: 4),
          ],
        ),
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
        body: ListView(
          controller: scroll,
          padding: const EdgeInsets.only(bottom: 76),
          children: [
            Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: textTheme.headline5,
                    ),
                    if (info.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          info.description!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                  ],
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(16),
            //   child: Text(
            //     info.title,
            //     style: textTheme.headline5,
            //   ),
            // ),
            // if (info.description != null)
            //   Padding(
            //     padding: const EdgeInsets.all(16),
            //     child: Text(
            //       info.description!,
            //       style: const TextStyle(fontSize: 16),
            //     ),
            //   ),
            // const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: textTheme.caption?.copyWith(
                    fontSize: 14,
                  ),
                  children: [
                    if (info.tags?.isNotEmpty ?? false) ...[
                      const WidgetSpan(
                        child: SpanIcon(
                          Icons.tag_rounded,
                          padding: EdgeInsets.only(right: 4),
                        ),
                      ),
                      TextSpan(text: prettyTags(info.tags)! + '\n\n'),
                    ],
                    if (info.lastUpdateAt != null) ...[
                      const WidgetSpan(
                        child: SpanIcon(
                          Icons.update_outlined,
                          padding: EdgeInsets.only(right: 4),
                        ),
                      ),
                      TextSpan(
                        text: info.lastUpdateAt!
                            .toIso8601String()
                            .substring(0, 10),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
