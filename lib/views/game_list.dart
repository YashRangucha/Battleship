// lib/views/game_list.dart

import 'package:flutter/material.dart';
import '../models/game_list_item.dart';
import '../views/gamePage.dart';
import '../models/game_info.dart';
import '../utils/api.dart';
import '../views/gamedetailspage.dart';
import '../views/login_page.dart';

class GameList extends StatefulWidget {
  final String username;

  const GameList({Key? key, required this.username}) : super(key: key);

  @override
  _GameListState createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  List<GameInfo> games = [];
  bool showCompletedGames = false;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  void _loadGames() async {
    try {
      final gameDetails = await API.getGameDetails();
      if (gameDetails.containsKey('games')) {
        final List<GameInfo> loadedGames = [];

        for (final game in gameDetails['games']) {
          final int gameId = game['id'];
          final String status = _getStatusText(game['status']);
          final String? player1 = game['player1'];
          final String? player2 = game['player2'];
          final int position = game['position'];
          final int turn = game['turn'];

          loadedGames.add(GameInfo(
            id: gameId,
            status: status,
            player1: player1,
            player2: player2,
            position: position,
            turn: turn,
          ));
        }

        setState(() {
          games = loadedGames;
        });
      } else {
        throw Exception('Invalid API response: Missing "games" key');
      }
    } catch (e) {
      print('Failed to load games: $e');
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Matchmaking';
      case 1:
        return 'Player 1 won';
      case 2:
        return 'Player 2 won';
      case 3:
        return 'Active';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<GameInfo> filteredGames = showCompletedGames
        ? games
            .where((game) =>
                game.status == 'Player 1 won' || game.status == 'Player 2 won')
            .toList()
        : games
            .where((game) =>
                game.status != 'Player 1 won' && game.status != 'Player 2 won')
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battleships'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Tooltip(
                message: 'Refresh Games', child: Icon(Icons.refresh)),
            onPressed: _loadGames,
          ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Tooltip(
                  message: 'Open Navigation Bar', child: Icon(Icons.menu)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Battleships',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Logged in as ${widget.username}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.add, 'Start New Game', _startNewGame),
            _buildDrawerItem(
                Icons.android, 'Start a Game with AI', _startGameWithAI),
            _buildDrawerItem(
                Icons.history,
                showCompletedGames
                    ? 'Show Active Games'
                    : 'Show Completed Games',
                _toggleGameStatus),
            _buildDrawerItem(Icons.logout, 'Logout', _logout),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: filteredGames.length,
        itemBuilder: (context, index) {
          final game = filteredGames[index];
          return game.status == 'Player 1 won' || game.status == 'Player 2 won'
              ? _buildCompletedGameItem(game)
              : _buildActiveGameItem(game);
        },
      ),
    );
  }

  Widget _buildCompletedGameItem(GameInfo game) {
    return GameListItem(
      game: game,
      onTap: () => _onGameTap(game),
      additionalInfo: '${game.player1} vs ${game.player2 ?? 'None'}',
    );
  }

  Widget _buildActiveGameItem(GameInfo game) {
    return Dismissible(
      key: Key(game.id.toString()),
      onDismissed: (direction) {
        _deleteGame(game.id);
      },
      background: Container(
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
      ),
      child: GameListItem(
        game: game,
        onTap: () => _onGameTap(game),
        additionalInfo: '${game.player1} vs ${game.player2 ?? 'None'}',
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _onGameTap(GameInfo game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailsPage(
          gameId: game.id,
          isMyTurn: game.turn == game.position,
        ),
      ),
    );
  }

  void _logout() async {
    await API.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _startNewGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GamePage()),
    );
  }

  void _startGameWithAI() {
    String selectedAI = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose AI Opponent'),
          content: Column(
            children: [
              _buildAIOption('Random', selectedAI == 'Random', () {
                selectedAI = 'Random';
                Navigator.pop(context);
                _startGame(selectedAI);
              }),
              _buildAIOption('Perfect', selectedAI == 'Perfect', () {
                selectedAI = 'Perfect';
                Navigator.pop(context);
                _startGame(selectedAI);
              }),
              _buildAIOption('One Ship', selectedAI == 'OneShip', () {
                selectedAI = 'OneShip';
                Navigator.pop(context);
                _startGame(selectedAI);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIOption(String aiType, bool isSelected, VoidCallback onTap) {
    return ListTile(
      title: Text(aiType),
      onTap: onTap,
      tileColor: isSelected ? const Color.fromARGB(255, 131, 232, 124) : null,
    );
  }

  void _deleteGame(int gameId) async {
    final game = games.firstWhere((g) => g.id == gameId);

    if (game.status == 'Player 1 won' || game.status == 'Player 2 won') {
      _showSnackbar('Cannot forfeit a completed game');
    } else {
      await API.cancelGame(gameId);
      _showSnackbar('Game forfeited successfully');
      _loadGames();
    }
  }

  void _toggleGameStatus() {
    setState(() {
      showCompletedGames = !showCompletedGames;
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _startGame(String selectedAI) {
    if (selectedAI.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GamePage(ai: selectedAI),
        ),
      );
    }
  }
}
