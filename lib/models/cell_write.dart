import 'package:json_annotation/json_annotation.dart';

part 'cell_write.g.dart';

enum CellWriteMode {
  overwrite,
  add,
  subtract,
}

@JsonSerializable()
class CellWrite {
  String targetCellId;
  String value;
  CellWriteMode mode;

  CellWrite(
    this.targetCellId, {
    this.value = '',
    this.mode = CellWriteMode.overwrite,
  });

  factory CellWrite.fromJson(Map<String, dynamic> json) =>
      _$CellWriteFromJson(json);

  Map<String, dynamic> toJson() => _$CellWriteToJson(this);
}
