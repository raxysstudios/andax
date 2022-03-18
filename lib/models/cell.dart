import 'dart:core';
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

  bool get numeric => max != null;

  String _value = '';
  String get value => _value;
  set value(String v) {
    if (!numeric) {
      _value = v;
      return;
    }

    var num = 0;
    if (v.length > 1 && v[1] == ' ') {
      final oldNum = int.tryParse(_value) ?? 0;
      num = int.tryParse(v.substring(2)) ?? 0;
      switch (v[0]) {
        case '+':
          num = oldNum + num;
          break;
        case '-':
          num = oldNum - num;
          break;
      }
    } else {
      num = int.tryParse(v) ?? 0;
    }
    if (max! > 0) num = num.clamp(0, max!);
    _value = num.toString();
  }

  factory Cell.fromJson(Map<String, dynamic> json) => _$CellFromJson(json);

  Map<String, dynamic> toJson() => _$CellToJson(this);
}
