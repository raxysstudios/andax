import 'dart:core';
import 'package:andax/models/cell_write.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cell.g.dart';

enum CellDisplay { check, text, range }

@JsonSerializable()
class Cell {
  Cell(
    this.id, {
    this.max,
    this.display,
  });

  final String id;
  CellDisplay? display;
  int? max;

  String value = '';

  void apply(CellWrite write) {
    if (write.mode == CellWriteMode.overwrite) {
      value = write.value;
      return;
    }

    final oldNum = int.tryParse(value) ?? 0;
    var num = int.tryParse(write.value) ?? 0;
    if (write.mode == CellWriteMode.subtract) num *= -1;
    num = oldNum + num;

    final max = this.max;
    if (max != null && max > 0) num = num.clamp(0, max);
    value = num.toString();
  }

  factory Cell.fromJson(Map<String, dynamic> json) => _$CellFromJson(json);

  Map<String, dynamic> toJson() => _$CellToJson(this);
}
