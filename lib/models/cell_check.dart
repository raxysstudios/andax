import 'package:andax/models/cell.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cell_check.g.dart';

enum CheckOperator { pass, equal, less, greater }

@JsonSerializable()
class CellCheck {
  String cellId;
  CheckOperator operator;
  String value = '';

  CellCheck({
    required this.cellId,
    this.operator = CheckOperator.pass,
    this.value = '',
  });

  factory CellCheck.fromJson(Map<String, dynamic> json) =>
      _$CellCheckFromJson(json);

  Map<String, dynamic> toJson() => _$CellCheckToJson(this);

  bool check(Map<String, Cell> cells) {
    final x = cells[cellId]?.value;
    if (x == null) return false;
    switch (operator) {
      case CheckOperator.pass:
        return true;
      case CheckOperator.equal:
        return x == value;
      case CheckOperator.less:
        return (num.tryParse(x) ?? 0) < (num.tryParse(value) ?? 0);
      case CheckOperator.greater:
        return (num.tryParse(x) ?? 0) > (num.tryParse(value) ?? 0);
    }
  }
}
