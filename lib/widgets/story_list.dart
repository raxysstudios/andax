import 'dart:async';

import 'package:andax/models/story.dart';
import 'package:andax/utils.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class StoryList extends StatefulWidget {
  const StoryList({
    required this.onRequest,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final Future<List<StoryInfo>> Function(int) onRequest;
  final ValueSetter<StoryInfo>? onTap;

  @override
  State<StoryList> createState() => _StoryListState();
}

class _StoryListState extends State<StoryList> {
  late final PagingController<int, StoryInfo> paging;

  @override
  void initState() {
    super.initState();
    paging = PagingController<int, StoryInfo>(
      firstPageKey: 0,
    );
    paging.addPageRequestListener(
      (page) async {
        final stories = await widget.onRequest(page);
        if (stories.isEmpty) {
          paging.appendLastPage([]);
        } else {
          paging.appendPage(stories, page + 1);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => paging.refresh(),
      ),
      child: PagedListView<int, StoryInfo>(
        pagingController: paging,
        builderDelegate: PagedChildBuilderDelegate(
          itemBuilder: (context, info, index) {
            return ListTile(
              title: Text(info.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (info.description == null) Text(info.description!),
                  if (info.tags != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.tag_rounded,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(prettyTags(info.tags)!),
                      ],
                    ),
                ],
              ),
              trailing: Chip(
                avatar: const Icon(
                  Icons.favorite_rounded,
                  size: 16,
                ),
                label: Text(info.likes.toString()),
              ),
              onTap:
                  widget.onTap == null ? null : () => widget.onTap!.call(info),
            );
          },
        ),
      ),
    );
  }
}
