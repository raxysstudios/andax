import 'package:enum_to_string/enum_to_string.dart';
import 'package:andax/utils.dart';

enum ScenarioEnding { win, loss }

class NodeChoice {
  String id;
  String note;
  String targetNodeId;

  NodeChoice({
    required this.id,
    required this.note,
    required this.targetNodeId,
  });
}

class ScenarioNode {
  String id;
  String note;
  ScenarioEnding? ending;
  List<NodeChoice>? choices;

  ScenarioNode({
    required this.id,
    required this.note,
    this.ending,
    this.choices,
  });

  ScenarioNode.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          note: json['note'],
          ending: EnumToString.fromString(
            ScenarioEnding.values,
            json['ending'],
          ),
          choices: listFromJson<NodeChoice>(
            json['choices'],
            (j) => NodeChoice(
              id: j['id'],
              note: j['note'],
              targetNodeId: j['targetNoteId'],
            ),
          ),
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'ending': ending,
      'choices': choices?.map(
        (c) => {
          'id': c.id,
          'note': c.note,
          'targetNodeId': c.targetNodeId,
        },
      ),
    };
  }
}
