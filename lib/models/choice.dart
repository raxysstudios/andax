class Choice {
  String id;
  String targetNodeId;

  Choice({
    required this.id,
    required this.targetNodeId,
  });

  Choice.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          targetNodeId: json['targetNodeId'],
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetNodeId': targetNodeId,
      };
}
