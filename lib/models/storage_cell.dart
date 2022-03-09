import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'storage_cell.g.dart';

@JsonSerializable()
class StorageCell {
  StorageCell(this.id, {this.max});

  final String id;
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
    _value = num.clamp(0, max!).toString();
  }

  factory StorageCell.fromJson(Map<String, dynamic> json) =>
      _$StorageCellFromJson(json);

  Map<String, dynamic> toJson() => _$StorageCellToJson(this);
}
