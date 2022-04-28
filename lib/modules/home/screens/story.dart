import 'package:andax/models/story.dart';
import 'package:andax/modules/editor/screens/story.dart';
import 'package:andax/modules/home/widgets/gradient_cover_image.dart';
import 'package:andax/modules/home/widgets/like_chip.dart';
import 'package:andax/modules/play/screens/play.dart';
import 'package:andax/modules/translation/services/translations.dart';
import 'package:andax/shared/services/story_loader.dart';
import 'package:andax/shared/utils.dart';
import 'package:andax/shared/widgets/column_card.dart';
import 'package:andax/shared/widgets/markdown_text.dart';
import 'package:andax/shared/widgets/options_button.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:andax/shared/widgets/span_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
            forceElevated: true,
            leading: const RoundedBackButton(),
            expandedHeight: info.imageUrl.isEmpty ? null : 3 * kToolbarHeight,
            flexibleSpace: info.imageUrl.isEmpty
                ? null
                : FlexibleSpaceBar(
                    background: GradientCoverImage(info.imageUrl),
                  ),
            actions: [
              Chip(
                avatar: const Icon(Icons.visibility_rounded),
                label: Text(info.views.toString()),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(width: 8),
              LikeChip(info),
              const SizedBox(width: 8),
              OptionsButton(
                [
                  OptionItem.simple(
                    Icons.report_rounded,
                    'Report',
                  ),
                  if (user != null) ...[
                    OptionItem.divider(),
                    OptionItem.simple(
                      Icons.translate_rounded,
                      'New translation',
                      () => addTranslation(context, info),
                    ),
                    OptionItem.simple(
                      Icons.translate_rounded,
                      'Edit translation',
                      () => selectBaseTranslation(context, info),
                    ),
                    if (user.uid == info.storyAuthorID)
                      OptionItem.simple(
                        Icons.edit_rounded,
                        'Edit story',
                        () => loadStory(
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
                      ),
                  ],
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ColumnCard(
                  divider: const SizedBox(
                    height: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      info.title,
                      style: textTheme.headline5?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (info.description.isNotEmpty)
                      MarkdownText(info.description),
                  ],
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
                        if (info.tags.isNotEmpty) ...[
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
