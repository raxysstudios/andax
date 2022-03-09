import 'package:andax/models/storage_cell.dart';
import 'package:flutter/material.dart';

class StorageCellTile extends StatelessWidget {
  const StorageCellTile(
    this.cell, {
    this.onTap,
    Key? key,
  }) : super(key: key);

  final StorageCell cell;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        cell.numeric ? Icons.calculate_rounded : Icons.text_fields_rounded,
      ),
      title: Text(cell.value),
      trailing: cell.numeric ? Text('/ ${cell.max}') : null,
      onTap: onTap,
    );
  }
}
