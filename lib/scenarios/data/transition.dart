class Transition {
  String id;
  String targetNodeId;

  Transition({
    required this.id,
    required this.targetNodeId,
  });

  Transition.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          targetNodeId: json['targetNodeId'],
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetNodeId': targetNodeId,
      };
}
