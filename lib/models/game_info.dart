class GameInfo {
  final int id;
  final String status;
  final String? player1;
  final String? player2;
  final int position;
  final int turn;

  GameInfo({
    required this.id,
    required this.status,
    this.player1,
    this.player2,
    required this.position,
    required this.turn,
  });
}
