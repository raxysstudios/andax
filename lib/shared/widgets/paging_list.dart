import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PagingList<T> extends StatelessWidget {
  final Widget Function(BuildContext, T, int) builder;
  final Future<List<T>> Function(int, T?) onRequest;
  final ScrollController? scroll;
  final int? maxPages;
  final PagingController<int, T> paging;

  PagingList({
    required this.onRequest,
    required this.builder,
    PagingController<int, T>? controller,
    this.maxPages,
    this.scroll,
    Key? key,
  })  : paging = controller ??
            PagingController<int, T>(
              firstPageKey: 0,
            ),
        super(key: key) {
    paging.addPageRequestListener((page) async {
      if (maxPages != null && page >= maxPages!) {
        paging.appendLastPage([]);
      }
      final items = await onRequest(page, paging.itemList?.last);
      if (items.isEmpty) {
        paging.appendLastPage([]);
      } else {
        paging.appendPage(items, page + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => paging.refresh(),
      ),
      child: PagedListView<int, T>(
        pagingController: paging,
        scrollController: scroll,
        builderDelegate: PagedChildBuilderDelegate(
          itemBuilder: builder,
        ),
      ),
    );
  }
}
