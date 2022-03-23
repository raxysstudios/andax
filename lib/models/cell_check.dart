import 'package:andax/models/story.dart';

enum CheckOperator { pass, equal, less, greater }

class CellCheck {
  String cellId;
  CheckOperator operator;
  String value = '';

  CellCheck({
    required this.cellId,
    this.operator = CheckOperator.pass,
    this.value = '',
  });

  bool check(Story story) {
    final x = story.cells[cellId]?.value;
    if (x == null) return false;
    switch (operator) {
      case CheckOperator.pass:
        return true;
      case CheckOperator.equal:
        return x == value;
      case CheckOperator.less:
        return (int.tryParse(x) ?? 0) < (int.tryParse(value) ?? 0);
      case CheckOperator.greater:
        return (int.tryParse(x) ?? 0) > (int.tryParse(value) ?? 0);
    }
  }
}
