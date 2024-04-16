class GameListItemsInfo {
  final int id;
  final String status;
  final String? player1;
  final String? player2;

  GameListItemsInfo({
    required this.id,
    required this.status,
    this.player1,
    this.player2,
  });
}
