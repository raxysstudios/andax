import 'package:andax/models/story.dart';
import 'package:andax/modules/play/screens/play.dart';
import 'package:andax/shared/services/story_loader.dart';
import 'package:andax/shared/widgets/column_card.dart';
import 'package:andax/shared/widgets/markdown_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/gradient_cover_image.dart';
import 'home.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen(this.info, {Key? key}) : super(key: key);

  final StoryInfo info;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  void play() async {
    await loadStory(
      context,
      widget.info,
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
    exit();
  }

  void exit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);

    if (!mounted) return;
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: play,
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Play'),
      ),
      appBar: AppBar(toolbarHeight: 0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            forceElevated: true,
            leading: IconButton(
              onPressed: exit,
              icon: const Icon(Icons.close_rounded),
            ),
            expandedHeight: info.imageUrl.isEmpty ? null : 3 * kToolbarHeight,
            flexibleSpace: info.imageUrl.isEmpty
                ? null
                : FlexibleSpaceBar(
                    background: GradientCoverImage(info.imageUrl),
                  ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ColumnCard(
                  divider: const SizedBox(height: 8),
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
