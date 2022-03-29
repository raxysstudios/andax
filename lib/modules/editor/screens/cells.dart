import 'dart:async';
import 'package:andax/models/cell.dart';
import 'package:andax/modules/editor/widgets/cell_tile.dart';
import 'package:andax/shared/widgets/rounded_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/cell_editor.dart';
import 'story.dart';

class CellsEditorScreen extends StatelessWidget {
  const CellsEditorScreen({
    required this.onSelect,
    this.selectedId,
    this.scroll,
    Key? key,
  }) : super(key: key);

  final FutureOr<void> Function(Cell?, bool isNew) onSelect;
  final String? selectedId;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context) {
    final cells = context.watch<StoryEditorState>().story.cells.values.toList();
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Storage cells'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCellEditor(context).then((r) => onSelect(r, true)),
        icon: const Icon(Icons.post_add_rounded),
        label: const Text('Add cell'),
      ),
      body: ListView.builder(
        controller: scroll,
        padding: const EdgeInsets.only(bottom: 76),
        itemCount: cells.length,
        itemBuilder: (context, index) {
          final cell = cells[index];
          return CellTile(
            cell,
            onTap: () => onSelect(cell, false),
          );
        },
      ),
    );
  }
}
