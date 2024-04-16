import 'package:flutter/material.dart';
import '../utils/api.dart';
import '../models/GameDetails.dart';

class GameDetailsPage extends StatefulWidget {
  final int gameId;
  final bool isMyTurn;

  const GameDetailsPage(
      {Key? key, required this.gameId, required this.isMyTurn})
      : super(key: key);

  @override
  _GameDetailsPageState createState() => _GameDetailsPageState();
}

class _GameDetailsPageState extends State<GameDetailsPage> {
  late Future<GameDetails> _gameDetails;
  List<List<bool>> board = List.generate(5, (_) => List<bool>.filled(5, false));
  String selectedCoordinate = '';

  @override
  void initState() {
    super.initState();
    _gameDetails = _loadGameDetails();
  }

  Future<GameDetails> _loadGameDetails() async {
    final response = await API.getGameDetailsById(widget.gameId);
    return response;
  }

  Future<void> _playShot(String coordinate) async {
    final response = await API.playShot(widget.gameId, coordinate);
    final response1 = await API.getGameDetailsById(widget.gameId);
    setState(() {
      _gameDetails = _loadGameDetails();
    });
    if (response['sunk_ship'] == true) {
      _showSnackbar('Ship sunk! 💥');
    } else if (response['sunk_ship'] == false) {
      _showSnackbar('No Enemy Ship hit! 💣');
    } else if (response['error'] == "Not your turn") {
      _showSnackbar('Please wait until opponents plays a shot!');
    } else if (response['error'] == 'Shot already played') {
      _showSnackbar('Shot already played');
    } else if (response['error'] == 'Game not active') {
      _showSnackbar('Game is completed');
    }
    if (response1.status == response1.position &&
        response['error'] != 'Game not active') {
      Future.delayed(const Duration(milliseconds: 700), () {
        _showGameResultDialog('You won!', 'Well Played 🚀!');
      });
    } else if (response1.status != 3 &&
        response1.status != 0 &&
        response['error'] != 'Game not active') {
      Future.delayed(const Duration(milliseconds: 700), () {
        _showGameResultDialog('You lost the game!', 'Better luck next time');
      });
    }
  }

  void _showGameResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<GameDetails>(
          future: _gameDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return const Text('Game is in Matchmaking Mode');
            } else if (snapshot.hasData) {
              final game = snapshot.data!;
              return Text('Game ${game.id ?? 'Unknown'} ');
            } else {
              return const Text('');
            }
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<GameDetails>(
        future: _gameDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Sorry, Please come back again.'));
          } else if (snapshot.hasData) {
            final game = snapshot.data!;
            return _buildGameDetails(game);
          } else {
            return const Center(child: Text(''));
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () async {
                final response1 = await API.getGameDetailsById(widget.gameId);
                if (selectedCoordinate.isNotEmpty) {
                  _playShot(selectedCoordinate);
                } else if (response1.status != 3) {
                  _showSnackbar('Game is Completed');
                } else {
                  _showSnackbar('Oops!, Please select the ship to play shot');
                }
              },
              backgroundColor: Colors.blue,
              child: const Text('Submit'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildGameDetails(GameDetails game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildGameGrid(game)),
      ],
    );
  }

  Widget _buildGameGrid(GameDetails game) {
    final List<String> ships = game.ships ?? [];
    final List<String> wrecks = game.wrecks ?? [];
    final List<String> shots = game.shots ?? [];
    final List<String> sunk = game.sunk ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell size dynamically based on available width
        double cellSize = constraints.maxWidth / 6;
        double aspectRatio = 2.0;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            childAspectRatio: aspectRatio,
          ),
          itemCount: 36,
          itemBuilder: (context, index) {
            int row = index % 6;
            int col = index ~/ 6;

            final coordinate =
                '${String.fromCharCode('A'.codeUnitAt(0) + col - 1)}${row - 1 + 1}';
            final isShip = ships.contains(coordinate);
            final isWreck = wrecks.contains(coordinate);
            final isShot =
                shots.contains(coordinate) && !sunk.contains(coordinate);
            final isSunk =
                sunk.contains(coordinate) && shots.contains(coordinate);

            bool isSelected = selectedCoordinate == coordinate;

            if (row == 0 && col == 0) {
              return Container();
            } else if (row == 0) {
              return Container(
                alignment: Alignment.center,
                child: Text(
                  '${String.fromCharCode('A'.codeUnitAt(0) + col - 1)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            } else if (col == 0) {
              return Container(
                alignment: Alignment.center,
                child: Text(
                  '$row',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            } else {
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedCoordinate = '';
                    } else {
                      selectedCoordinate = coordinate;
                    }
                  });
                },
                child: Container(
                  width: cellSize,
                  height: cellSize * aspectRatio,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromARGB(255, 131, 232, 124)
                        : (selectedCoordinate.isNotEmpty)
                            ? Colors.white
                            : board[row - 1][col - 1]
                                ? Colors.blue
                                : Colors.white,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isShip
                            ? const Text('🚢',
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white))
                            : const SizedBox(),
                        isWreck
                            ? const Text('🫧',
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white))
                            : const SizedBox(),
                        isShot
                            ? const Text('💣',
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white))
                            : const SizedBox(),
                        isSunk
                            ? const Text('💥',
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white))
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
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
}
