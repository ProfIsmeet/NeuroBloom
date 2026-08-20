class GameCompletion {
  const GameCompletion({required this.gameId, required this.date});

  final String gameId;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'date': date.toIso8601String(),
  };

  static GameCompletion? tryParse(dynamic json) {
    if (json is! Map) return null;
    final gameId = json['gameId'];
    final dateStr = json['date'];
    if (gameId is! String || dateStr is! String) return null;
    final date = DateTime.tryParse(dateStr);
    if (date == null) return null;
    return GameCompletion(gameId: gameId, date: date);
  }
}
