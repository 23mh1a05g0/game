class Player {
  final String name;
  final String avatar;
  int highScore;

  Player({
    required this.name,
    required this.avatar,
    this.highScore = 0,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatar': avatar,
        'highScore': highScore,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        name: json['name'],
        avatar: json['avatar'],
        highScore: json['highScore'] ?? 0,
      );
}
