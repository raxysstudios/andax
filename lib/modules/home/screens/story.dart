import 'package:andax/models/story.dart';
import 'package:andax/modules/home/widgets/gradient_cover_image.dart';
import 'package:andax/modules/home/widgets/like_chip.dart';
import 'package:andax/modules/store_play/screens/play.dart';
import 'package:andax/modules/story_editor/screens/story_editor.dart';
import 'package:andax/shared/services/story_loader.dart';
import 'package:andax/shared/utils.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/span_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen(
    this.info, {
    this.scroll,
    Key? key,
  }) : super(key: key);

  final StoryInfo info;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;
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
            pinned: true,
            leading: const RoundedBackButton(),
            expandedHeight: 3 * kToolbarHeight,
            flexibleSpace: FlexibleSpaceBar(
              background: GradientCoverImage(
                info.imageUrl,
                placeholderSize: 128,
                step: 0,
              ),
            ),
            actions: [
              Chip(
                avatar: const Icon(Icons.visibility_rounded),
                label: Text(info.views.toString()),
              ),
              const SizedBox(width: 8),
              LikeChip(info),
              const SizedBox(width: 8),
              PopupMenuButton<void>(itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      // Should point to a cloud function probably.
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
                      onTap: () {
                        // Crowdsroucing is broken at the moment.
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
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.title,
                          style: textTheme.headline5?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (info.description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: MarkdownBody(
                              data: info.description!,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(
                                  fontSize: 16,
                                ),
                                strong: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTapLink: (_, link, __) {
                                if (link != null) launch(link);
                              },
                            ),
                          )
                      ],
                    ),
                  ),
                ),
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
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 76,
            ),
          )
        ],
      ),
    );
  }
}
