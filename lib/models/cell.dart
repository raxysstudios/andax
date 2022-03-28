import 'dart:core';
import 'package:andax/models/cell_write.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cell.g.dart';

enum CellDisplay { check, text, range }

@JsonSerializable()
class Cell {
  Cell(
    this.id, {
    this.max = double.infinity,
    this.display,
  });

  final String id;
  CellDisplay? display;
  num max;

  String value = '';

  void apply(CellWrite write) {
    if (write.mode == CellWriteMode.overwrite) {
      value = write.value;
      return;
    }

    num n = int.tryParse(write.value) ?? 0;
    if (write.mode == CellWriteMode.subtract) n *= -1;
    n = (int.tryParse(value) ?? 0) + n;
    n = n.clamp(0, max);
    value = n.toString();
  }

  factory Cell.fromJson(Map<String, dynamic> json) => _$CellFromJson(json);

  Map<String, dynamic> toJson() => _$CellToJson(this);
}
