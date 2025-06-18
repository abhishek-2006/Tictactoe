import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class EasyMode extends StatefulWidget {
  const EasyMode({Key? key}) : super(key: key);

  @override
  _EasyModeState createState() => _EasyModeState();
}

class _EasyModeState extends State<EasyMode> {
  late List<List<String>> _board;
  late String _currentPlayer;
  late bool _gameOver;
  late String _winner;
  final Random _random = Random();

  int _playerXScore = 0;
  int _cpuScore = 0;

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
      _winner = '';
    });
  }

  void _handleTap(int row, int col) {
    if (_board[row][col] == '' && !_gameOver) {
      setState(() {
        _board[row][col] = _currentPlayer;
        if (_checkWinner(row, col)) {
          _gameOver = true;
          _winner = _currentPlayer;
          _updateScore(_winner);
          _showGameResultDialog();
        } else if (_isBoardFull()) {
          _gameOver = true;
          _showGameResultDialog();
        } else {
          _currentPlayer = 'O';
          Future.delayed(Duration(milliseconds: 700), _makeBestMove);
        }
      });
    }
  }

  void _showGameResultDialog() {
    String title;
    String subtitle;

    if (_winner == 'X') {
      title = 'Congrats, You Win!';
      subtitle = 'Great job!';
    } else if (_winner == 'O') {
      title = 'CPU WINS';
      subtitle = 'Better luck next time!';
    } else {
      title = 'IT\'S A DRAW';
      subtitle = 'Try harder next time!';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
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
                const SizedBox(height: 20),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
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

  void _updateScore(String winner) {
    if (winner == 'X') {
      _playerXScore++;
    } else if (winner == 'O') {
      _cpuScore++;
    }
  }

  void _makeBestMove() {
    if (_gameOver) return;

    if (_random.nextDouble() < 0.35) {
      int bestScore = -1000;
      int bestRow = -1;
      int bestCol = -1;

      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          if (_board[row][col] == '') {
            _board[row][col] = 'O';
            int score = _minimax(_board, 0, false);
            _board[row][col] = '';
            if (score > bestScore) {
              bestScore = score;
              bestRow = row;
              bestCol = col;
            }
          }
        }
      }

      setState(() {
        _board[bestRow][bestCol] = 'O';
        if (_checkWinner(bestRow, bestCol)) {
          _gameOver = true;
          _winner = 'O';
          _updateScore(_winner);
          _showGameResultDialog();
        } else if (_isBoardFull()) {
          _gameOver = true;
          _showGameResultDialog();
        } else {
          _currentPlayer = 'X';
        }
      });
    } else {
      List<int> emptyCells = [];
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          if (_board[row][col] == '') {
            emptyCells.add(row * 3 + col);
          }
        }
      }

      int randomMove = emptyCells[_random.nextInt(emptyCells.length)];
      int row = randomMove ~/ 3;
      int col = randomMove % 3;

      setState(() {
        _board[row][col] = 'O';
        if (_checkWinner(row, col)) {
          _gameOver = true;
          _winner = 'O';
          _updateScore(_winner);
          _showGameResultDialog();
        } else if (_isBoardFull()) {
          _gameOver = true;
          _showGameResultDialog();
        } else {
          _currentPlayer = 'X';
        }
      });
    }
  }

  int _minimax(List<List<String>> board, int depth, bool isMaximizing) {
    if (_checkWinnerAI(board, 'O')) return 1;
    if (_checkWinnerAI(board, 'X')) return -1;
    if (_isBoardFull()) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          if (board[row][col] == '') {
            board[row][col] = 'O';
            int score = _minimax(board, depth + 1, false);
            board[row][col] = '';
            bestScore = max(score, bestScore);
          }
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          if (board[row][col] == '') {
            board[row][col] = 'X';
            int score = _minimax(board, depth + 1, true);
            board[row][col] = '';
            bestScore = min(score, bestScore);
          }
        }
      }
      return bestScore;
    }
  }

  bool _checkWinnerAI(List<List<String>> board, String player) {
    for (int row = 0; row < 3; row++) {
      if (board[row].every((cell) => cell == player)) return true;
    }
    for (int col = 0; col < 3; col++) {
      if (board.every((row) => row[col] == player)) return true;
    }
    if (board[0][0] == player && board[1][1] == player && board[2][2] == player) return true;
    if (board[0][2] == player && board[1][1] == player && board[2][0] == player) return true;
    return false;
  }

  bool _checkWinner(int row, int col) {
    if (_board[row].every((cell) => cell == _currentPlayer)) return true;
    if (_board.every((row) => row[col] == _currentPlayer)) return true;
    if (row == col && _board.every((row) => row[_board.indexOf(row)] == _currentPlayer)) return true;
    if (row + col == 2 && _board.every((row) => row[2 - _board.indexOf(row)] == _currentPlayer)) return true;
    return false;
  }

  bool _isBoardFull() {
    return _board.every((row) => row.every((cell) => cell != ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDDF0F8),
      appBar: AppBar(
        backgroundColor: Color(0xFF6B9DCF),
        title: const Text('Easy Mode'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          _buildScoreBoard(),
          const SizedBox(height: 35),
          _buildBoard(),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Player $_currentPlayer's Turn",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Container(
            width: 330,
            child: Table(
              border: TableBorder.symmetric(
                inside: const BorderSide(width: 3, color: Colors.black),
              ),
              children: List.generate(3, (row) {
                return TableRow(
                  children: List.generate(3, (col) => _buildCell(row, col)),
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
        decoration: const BoxDecoration(border: Border()),
        child: Center(
          child: Text(
            _board[row][col],
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
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

  Widget _buildScoreBoard() {
    return Column(
      children: [
        const Text(
          'Player (X)     CPU (O)',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          '    $_playerXScore               $_cpuScore',
          style: const TextStyle(fontSize: 24),
        ),
      ],
    );
  }
}

int min(int a, int b) => (a < b) ? a : b;
int max(int a, int b) => (a > b) ? a : b;