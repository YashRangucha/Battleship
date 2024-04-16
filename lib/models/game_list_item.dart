// lib/views/game_list_item.dart

import 'package:flutter/material.dart';
import '../models/game_info.dart';

class GameListItem extends StatelessWidget {
  final GameInfo game;
  final VoidCallback onTap;
  final String additionalInfo;

  const GameListItem({
    Key? key,
    required this.game,
    required this.onTap,
    required this.additionalInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        'Game ${game.id}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Players:'),
          Text(
            additionalInfo,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildSubtitle(game),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSubtitle(GameInfo game) {
    if (game.player1 != null && game.player2 != null) {
      String turnText = '';
      if (game.status == 'Active') {
        if (game.turn == game.position) {
          turnText = 'My Turn';
        } else {
          turnText = 'Opponent\'s Turn';
        }
      }
      return Text(
        'Status: ${game.status}\n$turnText',
        style: TextStyle(fontWeight: FontWeight.w600),
      );
    } else {
      return Text('Status: ${game.status}');
    }
  }
}
