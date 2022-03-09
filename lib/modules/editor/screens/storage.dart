import 'dart:async';
import 'package:andax/models/storage_cell.dart';
import 'package:andax/modules/editor/widgets/storage_cell_tile.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/storage_cell_dialog.dart';
import 'story.dart';

class StorageEditorScreen extends StatelessWidget {
  const StorageEditorScreen(
    this.onSelect, {
    this.selectedId,
    this.scroll,
    Key? key,
  }) : super(key: key);

  final FutureOr<void> Function(StorageCell?, bool isNew) onSelect;
  final String? selectedId;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context) {
    final cells =
        context.watch<StoryEditorState>().story.storage.values.toList();
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Storage cells'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showStorageCellEditorDialog(
          context
        ).then((r) => onSelect(r, true)),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add actor'),
      ),
      body: ListView.builder(
        controller: scroll,
        padding: const EdgeInsets.only(bottom: 76),
        itemCount: cells.length,
        itemBuilder: (context, index) {
          final cell = cells[index];
          return StorageCellTile(
            cell,
            onTap: () => onSelect(cell, false),
          );
        },
      ),
    );
  }
}
