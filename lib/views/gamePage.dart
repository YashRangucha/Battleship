import 'package:flutter/material.dart';
import '../models/game_list_items_info.dart';
import '../utils/api.dart';

class GamePage extends StatefulWidget {
  final String? ai; // Optional AI opponent
  const GamePage({Key? key, GameListItemsInfo? game, this.ai})
      : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<List<bool>> board = List.generate(5, (_) => List<bool>.filled(5, false));
  int shipsPlaced = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Your Ships'),
      ),
      body: Column(
        children: [
          // Display labels for rows (A to E) and the game board
          Row(
            children: [
              Container(
                width: 30,
              ),
              // Display labels for columns (1 to 5)
              for (var i = 1; i <= 5; i++)
                Expanded(
                  child: Container(
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    child: Text(
                      '$i',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                // Display labels for rows (A to E)
                Column(
                  children: [
                    for (var i = 0; i < 5; i++)
                      Expanded(
                        child: Container(
                          width: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                          ),
                          child: Text(
                            String.fromCharCode('A'.codeUnitAt(0) + i),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                // Display the game board cells
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cellSize = _calculateCellSize(constraints);

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: 25,
                        itemBuilder: (context, index) {
                          final row = index ~/ 5;
                          final col = index % 5;

                          return InkWell(
                            onTap: () {
                              _toggleShipPlacement(row, col);
                            },
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: board[row][col]
                                    ? Colors.blue
                                    : Colors.white,
                              ),
                              child: Center(
                                child: board[row][col]
                                    ? const Icon(Icons.directions_boat,
                                        color: Colors.white)
                                    : null,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Button to submit the ship configuration
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      shipsPlaced == 5 ? () => _submitShips(context) : null,
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(color: Colors.white),
                    backgroundColor:
                        shipsPlaced == 5 ? Colors.blue : Colors.grey,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to calculate cell size based on screen dimensions
  double _calculateCellSize(BoxConstraints constraints) {
    double minWidth = constraints.minWidth;
    double minHeight = constraints.minHeight;

    // Adjust the cell size based on the smaller dimension
    double cellSize = (minWidth < minHeight) ? minWidth / 7 : minHeight / 7;

    // Ensure the cell size is not too large
    return cellSize > 50 ? 50 : cellSize;
  }

  // Function to toggle ship placement on the board
  void _toggleShipPlacement(int row, int col) {
    setState(() {
      if (board[row][col]) {
        // If there's already a ship, remove it
        board[row][col] = false;
        shipsPlaced--;
      } else if (shipsPlaced < 5) {
        // If there's no ship and the user can place more ships, add a ship
        board[row][col] = true;
        shipsPlaced++;
      }
    });
  }

  // Function to submit the ship configuration to the server
  void _submitShips(BuildContext context) async {
    try {
      final ships = _getShipPositions();
      final response = await API.startGame(ships, widget.ai);

      // Handle the response and update the UI as needed
      // You can navigate to the game list page or handle the response accordingly
      // For now, just print the response to the console
      print(response);

      // You may want to navigate back to the game list page or navigate to the new game page
      Navigator.pop(context);
    } catch (e) {
      // Handle exceptions
      print('Error submitting ships: $e');
      // You may want to display an error message to the user
    }
  }

  // Function to extract ship positions from the board
  List<String> _getShipPositions() {
    final List<String> positions = [];
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        if (board[row][col]) {
          final position =
              '${String.fromCharCode('A'.codeUnitAt(0) + row)}${col + 1}';
          positions.add(position);
        }
      }
    }
    return positions;
  }
}
