class Transition {
  String id;
  String targetNodeId;
  int score;

  Transition(
    this.id, {
    required this.targetNodeId,
    this.score = 0,
  });

  Transition.fromJson(Map<String, dynamic> json)
      : this(
          json['id'] as String,
          targetNodeId: json['targetNodeId'] as String,
          score: json['score'] as int? ?? 0,
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'targetNodeId': targetNodeId,
        'score': score,
      };
}
