import 'dart:async';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PagingList<T> extends StatefulWidget {
  const PagingList({
    required this.onRequest,
    required this.builder,
    this.maxPages,
    this.scroll,
    Key? key,
  }) : super(key: key);

  final Widget Function(BuildContext, T, int) builder;
  final Future<List<T>> Function(int, T?) onRequest;
  final ScrollController? scroll;
  final int? maxPages;

  @override
  State<PagingList<T>> createState() => _PagingListState<T>();
}

class _PagingListState<T> extends State<PagingList<T>> {
  late final PagingController<int, T> paging;

  @override
  void initState() {
    super.initState();
    paging = PagingController<int, T>(
      firstPageKey: 0,
    );
    paging.addPageRequestListener(
      (page) async {
        if (widget.maxPages != null && page >= widget.maxPages!) {
          paging.appendLastPage([]);
        }
        final items = await widget.onRequest(page, paging.itemList?.last);
        if (items.isEmpty) {
          paging.appendLastPage([]);
        } else {
          paging.appendPage(items, page + 1);
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
      child: PagedListView<int, T>(
        pagingController: paging,
        scrollController: widget.scroll,
        builderDelegate: PagedChildBuilderDelegate(
          itemBuilder: widget.builder,
        ),
      ),
    );
  }
}
