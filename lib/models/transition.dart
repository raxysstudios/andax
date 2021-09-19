class Transition {
  String id;
  String targetNodeId;
  int score;

  Transition({
    required this.id,
    required this.targetNodeId,
    this.score = 0,
  });

  Transition.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          targetNodeId: json['targetNodeId'],
          score: json['score'] ?? 0,
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetNodeId': targetNodeId,
        'score': score,
      };
}