class Actor {
  String id;
  bool isPlayer;

  Actor({
    required this.id,
    this.isPlayer = false,
  });

  Actor.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          isPlayer: json['isPlayer'],
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'isPlayer': isPlayer,
      };
}
