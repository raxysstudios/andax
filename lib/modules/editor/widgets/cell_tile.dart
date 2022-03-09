import 'package:andax/models/cell.dart';
import 'package:flutter/material.dart';

class CellTile extends StatelessWidget {
  const CellTile(
    this.cell, {
    this.onTap,
    Key? key,
  }) : super(key: key);

  final Cell cell;
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
