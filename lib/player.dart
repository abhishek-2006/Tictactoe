import 'package:flutter/material.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6B9DCF),
        title: const Text('1v1 Player'),
      ),
      body: TicTacToeGame(),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  late List<List<String>> _board;
  late String _currentPlayer;
  late bool _gameOver;
  late String _winner;
  int _playerXScore = 0; // Player X's score
  int _playerOScore = 0; // Player O's score

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _board = List.generate(3, (_) => List.filled(3, ''));
      _currentPlayer = 'X';
      _gameOver = false;
      _winner = ''; // Initialize _winner as an empty string
    });
  }

  void _handleTap(int row, int col) {
    if (_board[row][col] == '' && !_gameOver) {
      setState(() {
        _board[row][col] = _currentPlayer;
        if (_checkWinner(row, col)) {
          _gameOver = true;
          _winner = _currentPlayer;
          _updateScore();
          _showGameResultDialog();
        } else if (_isBoardFull()) {
          _gameOver = true;
          _showGameResultDialog();
        } else {
          _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
        }
      });
    }
  }

  void _showGameResultDialog() {
    String title;

    if (_winner == 'X') {
      title = 'Player X Wins';
    } else if (_winner == 'O') {
      title = 'Player O Wins';
    } else {
      title = 'IT\'S A DRAW';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Dialog(
            backgroundColor: Colors.transparent,
            child: Center(
              child: Container(
                width: 350,
                padding: const EdgeInsets.symmetric(
                    vertical: 30, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2E2E), // dark card
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _resetGame();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        decoration: BoxDecoration(
                          color: Color(0xEF636363),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PLAY AGAIN',
                          style: TextStyle(
                            color: Color(0xFFECD875),
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _updateScore() {
    if (_winner == 'X') {
      _playerXScore++;
    } else if (_winner == 'O') {
      _playerOScore++;
    }
  }

  bool _checkWinner(int row, int col) {
    // Check row
    if (_board[row].every((cell) => cell == _currentPlayer)) {
      return true;
    }
    // Check column
    if (_board.every((row) => row[col] == _currentPlayer)) {
      return true;
    }
    // Check diagonals
    if (row == col &&
        _board.every((row) => row[_board.indexOf(row)] == _currentPlayer)) {
      return true;
    }
    if (row + col == 2 &&
        _board.every((row) => row[2 - _board.indexOf(row)] == _currentPlayer)) {
      return true;
    }
    return false;
  }

  bool _isBoardFull() {
    return _board.every((row) => row.every((cell) => cell != ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDDF0F8),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 80),
          _buildScoreBoard(),
          SizedBox(height: 30),
          _buildBoard(),
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text('Player X',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('$_playerXScore', style: TextStyle(fontSize: 22)),
            ],
          ),
          Column(
            children: [
              Text('Player O',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('$_playerOScore', style: TextStyle(fontSize: 22)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 20), // Space before the turn text
          Text(
            "Player $_currentPlayer's Turn",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 40), // Space between turn text and grid
          Container(
            width: 330, // Adjust this width as needed
            child: Table(
              border: TableBorder.symmetric(
                inside: BorderSide(
                  width: 3,
                  color: Colors.black,
                ),
              ),
              children: List.generate(3, (row) {
                return TableRow(
                  children: List.generate(3, (col) {
                    return _buildCell(row, col);
                  }),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    return GestureDetector(
      onTap: () => _handleTap(row, col),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          border: Border(),
        ),
        child: Center(
          child: Text(
            _board[row][col],
            style: TextStyle(
              fontSize: 40,
              color: _board[row][col] == 'X' ? Color(0xFFBF9F19) // Yellow
                  : _board[row][col] == 'O'
                  ? Color(0xFF1C89E3) // Blue
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}