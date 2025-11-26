import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import '../settings.dart'; // Import SoundManager and Settings

// --- THEME PALETTES ---
const Color _kDarkAccentColor = Color(0xFF00BCD4);
const Color _kDarkBackgroundColor = Color(0xFF0F172A);
const Color _kDarkCardColor = Color(0xFF1E293B);
const Color _kDarkTextColor = Colors.white;

const Color _kLightAccentColor = Color(0xFF00BCD4);
const Color _kLightBackgroundColor = Color(0xFFF0F4F8);
const Color _kLightCardColor = Colors.white;
const Color _kLightTextColor = Color(0xFF1E293B);

// Player Colors
const Color _kPlayerXColor = Color(0xFFBF9F19); // Gold
const Color _kPlayerOColor = Color(0xFF1C89E3); // Bright Blue

// Mode Color for Dialog (Easy Mode Green)
const Color _kEasyModeColor = Color(0xFF4CAF50);


class EasyMode extends StatefulWidget {
  final bool isDarkTheme;
  final Function(bool) onThemeChanged;
  const EasyMode({super.key, required this.isDarkTheme, required this.onThemeChanged});

  @override
  EasyModeState createState() => EasyModeState();
}

class EasyModeState extends State<EasyMode> with SingleTickerProviderStateMixin {
  // Game State and Logic
  List<List<String>> _board = List.generate(3, (_) => List.generate(3, (_) => ''));
  String _currentPlayer = 'X';
  bool _gameFinished = false;
  String _message = 'Player X\'s Turn';

  // 🏆 SCOREBOARD STATE
  int _playerXScore = 0;
  int _cpuOScore = 0;
  int _draws = 0;

  late AnimationController _controller;
  final SoundManager _soundManager = SoundManager();

  // Dynamic Color Getters
  Color get _currentBackgroundColor => widget.isDarkTheme ? _kDarkBackgroundColor : _kLightBackgroundColor;
  Color get _currentCardColor => widget.isDarkTheme ? _kDarkCardColor : _kLightCardColor;
  Color get _currentAccentColor => widget.isDarkTheme ? _kDarkAccentColor : _kLightAccentColor;
  Color get _currentAppBarTextColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;
  Color get _currentTextColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;
  Color get _currentBoardLineColor => widget.isDarkTheme ? _kDarkTextColor.withAlpha(128) : _kLightTextColor.withAlpha(128);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(int row, int col) {
    if (_board[row][col] == '' && !_gameFinished && _currentPlayer == 'X') {
      setState(() {
        _board[row][col] = 'X';
        if (_soundManager.isSoundOn) {
          _soundManager.playTapSound();
        }

        if (_checkWin(row, col)) {
          _gameFinished = true;
          _message = 'Player X Wins!';
          _playerXScore++;
          _showFinishDialog(_message);
        } else if (_checkDraw()) {
          _gameFinished = true;
          _message = 'It\'s a Draw!';
          _draws++;
          _showFinishDialog(_message);
        } else {
          _currentPlayer = 'O';
          _message = 'CPU\'s Turn';
          _runCpuTurn();
        }
      });
    } else if (_gameFinished) {
      _showFinishDialog(_message);
    }
  }

  void _runCpuTurn() {
    Timer(const Duration(milliseconds: 700), () {
      if (_gameFinished) return;

      List<List<int>> emptyCells = [];
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          if (_board[r][c] == '') {
            emptyCells.add([r, c]);
          }
        }
      }

      if (emptyCells.isNotEmpty) {
        // Easy Mode Logic: 40% chance of optimal move, 60% chance of random move
        Random random = Random();
        List<int> move;

        if (random.nextDouble() < 0.4) {
          // 40% chance: Optimal move (Minimax level 1 search for a win/block)
          move = _findOptimalMove(1);
        } else {
          // 60% chance: Random move
          move = emptyCells[random.nextInt(emptyCells.length)];
        }

        setState(() {
          if (_board[move[0]][move[1]] == '') {
            _board[move[0]][move[1]] = 'O';
            if (_soundManager.isSoundOn) {
              _soundManager.playTapSound();
            }

            if (_checkWin(move[0], move[1])) {
              _gameFinished = true;
              _message = 'CPU Wins!';
              _cpuOScore++;
              _showFinishDialog(_message);
            } else if (_checkDraw()) {
              _gameFinished = true;
              _message = 'It\'s a Draw!';
              _draws++;
              _showFinishDialog(_message);
            } else {
              _currentPlayer = 'X';
              _message = 'Player X\'s Turn';
            }
          }
        });
      }
    });
  }

  List<int> _findOptimalMove(int depth) {
    // 1. Check for winning move for 'O'
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (_board[r][c] == '') {
          _board[r][c] = 'O';
          if (_checkWin(r, c)) {
            _board[r][c] = ''; // Reset
            return [r, c];
          }
          _board[r][c] = ''; // Reset
        }
      }
    }

    // 2. Check for blocking move for 'X'
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (_board[r][c] == '') {
          _board[r][c] = 'X';
          if (_checkWin(r, c)) {
            _board[r][c] = ''; // Reset
            return [r, c];
          }
          _board[r][c] = ''; // Reset
        }
      }
    }

    // 3. Take center if available
    if (_board[1][1] == '') return [1, 1];

    // 4. Take a corner randomly
    List<List<int>> corners = [[0, 0], [0, 2], [2, 0], [2, 2]];
    corners.shuffle();
    for (var move in corners) {
      if (_board[move[0]][move[1]] == '') return move;
    }

    // Default to a random move if no strategic move is found
    List<List<int>> emptyCells = [];
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (_board[r][c] == '') {
          emptyCells.add([r, c]);
        }
      }
    }
    if (emptyCells.isNotEmpty) {
      return emptyCells[Random().nextInt(emptyCells.length)];
    }

    // Fallback
    return [-1, -1];
  }

  // Corrected win-check logic for diagonals
  bool _checkWin(int row, int col) {
    String player = _board[row][col];

    return (
        // 1. Check Row
        _board[row].every((cell) => cell == player) ||

            // 2. Check Column
            _board.every((r) => r[col] == player) ||

            // 3. Main Diagonal Check: checks cells [0,0], [1,1], [2,2]
            (row == col && List.generate(3, (i) => _board[i][i]).every((cell) => cell == player)) ||

            // 4. Anti-Diagonal Check: checks cells [0,2], [1,1], [2,0]
            (row + col == 2 && List.generate(3, (i) => _board[i][2 - i]).every((cell) => cell == player))
    );
  }

  bool _checkDraw() {
    return _board.every((row) => row.every((cell) => cell != ''));
  }

  void _resetGame() {
    setState(() {
      _board = List.generate(3, (_) => List.generate(3, (_) => ''));
      _currentPlayer = 'X';
      _gameFinished = false;
      _message = 'Player X\'s Turn';
      _controller.reset();
    });
  }

  void _showFinishDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: _currentCardColor,
          title: const Text(
            'Game Over',
            textAlign: TextAlign.center, // Center the title
            style: TextStyle(
              color: _kEasyModeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center, // Center the winning message
            style: TextStyle(
              color: _currentTextColor,
              fontSize: 18,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
                if (_soundManager.isVibrationOn) {
                  HapticFeedback.mediumImpact();
                }
              },
              child: const Text('Play Again', style: TextStyle(color: _kEasyModeColor)),
            ),
          ],
        );
      },
    );
  }

  // SCOREBOARD WIDGETS
  Widget _buildScoreboard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Player X Score
        _buildScoreColumn(
          label: 'PLAYER (X)',
          score: _playerXScore,
          color: _kPlayerXColor,
        ),
        // Draws Score
        _buildScoreColumn(
          label: 'DRAWS',
          score: _draws,
          color: _currentAccentColor,
        ),
        // CPU O Score
        _buildScoreColumn(
          label: 'CPU (O)',
          score: _cpuOScore,
          color: _kPlayerOColor,
        ),
      ],
    );
  }

  Widget _buildScoreColumn({required String label, required int score, required Color color}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color.withAlpha(204),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: color,
            shadows: [
              BoxShadow(
                color: color.withAlpha(102),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildBoard() {
    const double boardSize = 330;
    const double cellSize = boardSize / 3;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        color: _currentCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _currentBoardLineColor.withAlpha(77),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(
            width: 3,
            color: _currentBoardLineColor,
          ),
        ),
        children: List.generate(3, (row) {
          return TableRow(
            children: List.generate(3, (col) {
              return _buildCell(row, col, cellSize);
            }),
          );
        }),
      ),
    );
  }

  Widget _buildCell(int row, int col, double size) {
    return GestureDetector(
      onTap: () => _handleTap(row, col),
      child: Container(
        width: size,
        height: size,
        color: Colors.transparent,
        child: Center(
          child: Text(
            _board[row][col],
            style: TextStyle(
              fontSize: 55,
              fontWeight: FontWeight.w800,
              color: _board[row][col] == 'X' ? _kPlayerXColor : _kPlayerOColor,
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentBackgroundColor,
      appBar: AppBar(
        title: Text('EASY MODE (VS CPU)', style: TextStyle(color: _currentAppBarTextColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _currentAppBarTextColor),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _currentAppBarTextColor),
          onPressed: () {
            if (_soundManager.isVibrationOn) {
              HapticFeedback.mediumImpact();
            }
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              if (_soundManager.isVibrationOn) {
                HapticFeedback.lightImpact();
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings(
                  isDarkTheme: widget.isDarkTheme,
                  onThemeChanged: widget.onThemeChanged,
                )),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 80.0),
            _buildScoreboard(),

            // 2. SPACE (20.0 separation)
            const SizedBox(height: 80.0),

            // 3. CURRENT PLAYER MESSAGE
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0), // Space before board
              child: Text(
                _message,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _message.startsWith('Player X')
                      ? _kPlayerXColor
                      : _message.startsWith('CPU')
                      ? _kPlayerOColor
                      : _currentTextColor,
                ),
              ),
            ),

            // 4. GAME BOARD
            _buildBoard(),

            // 5. RESET BUTTON
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_soundManager.isVibrationOn) {
                    HapticFeedback.lightImpact();
                  }
                  if (_soundManager.isSoundOn) {
                    _soundManager.playTapSound();
                  }
                  _resetGame();
                },
                icon: const Icon(Icons.refresh, size: 28),
                label: const Text('New Game', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kEasyModeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}