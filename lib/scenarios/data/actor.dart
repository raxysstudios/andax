class Actor {
  late String id;

  Actor({
    required this.id,
  });

  Actor.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
        );

  Map<String, dynamic> toJson() => {
        'id': id,
      };
}
