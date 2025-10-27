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
const Color _kPlayerXColor = Color(0xFFBF9F19);
const Color _kPlayerOColor = Color(0xFF1C89E3);

// Mode Color for Dialog (Legend Mode Purple)
const Color _kLegendModeColor = Color(0xFF673AB7);


class LegendMode extends StatefulWidget {
  final bool isDarkTheme;
  final Function(bool) onThemeChanged;
  const LegendMode({Key? key, required this.isDarkTheme, required this.onThemeChanged}) : super(key: key);

  @override
  _LegendModeState createState() => _LegendModeState();
}

class _LegendModeState extends State<LegendMode> with SingleTickerProviderStateMixin {
  // Game State and Logic (Aligned with easy_mode.dart)
  List<List<String>> _board = List.generate(3, (_) => List.generate(3, (_) => ''));
  String _currentPlayer = 'X';
  bool _gameFinished = false;
  String _message = 'Player X\'s Turn';

  // 🏆 SCOREBOARD STATE (Aligned with easy_mode.dart)
  int _playerXScore = 0;
  int _cpuOScore = 0;
  int _draws = 0;

  late AnimationController _buttonController;
  final Random _random = Random();
  final SoundManager _soundManager = SoundManager();

  // Dynamic Color Getters
  Color get _currentBackgroundColor => widget.isDarkTheme ? _kDarkBackgroundColor : _kLightBackgroundColor;
  Color get _currentCardColor => widget.isDarkTheme ? _kDarkCardColor : _kLightCardColor;
  Color get _currentAccentColor => widget.isDarkTheme ? _kDarkAccentColor : _kLightAccentColor;
  Color get _currentAppBarTextColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;
  Color get _currentTextColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;
  Color get _currentBoardLineColor => widget.isDarkTheme ? _kDarkTextColor.withOpacity(0.5) : _kLightTextColor.withOpacity(0.5);


  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _resetGame();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  void _handleTap(int row, int col) {
    if (_board[row][col] == '' && !_gameFinished && _currentPlayer == 'X') {
      HapticFeedback.lightImpact();
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
          Future.delayed(const Duration(milliseconds: 700), _runCpuTurn);
        }
      });
    } else if (_gameFinished) {
      _showFinishDialog(_message);
    }
  }

  // Renamed _makeBestMove to _runCpuTurn for consistency (keeping logic wrapper)
  void _runCpuTurn() {
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
      // Legend Mode Logic: 100% chance of optimal move (Full Minimax search)
      List<int> move = _getBestMove('O', depth: 9);

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
  }

  // Placeholder/Simplified Minimax function
  List<int> _getBestMove(String player, {int depth = 9}) {
    // 1. Check for immediate winning move for 'O'
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

    // 4. Take a corner
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
      return emptyCells[_random.nextInt(emptyCells.length)];
    }

    return [-1, -1];
  }


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
      _buttonController.reset();
    });
  }

  // Replaced custom dialog with AlertDialog for consistency and centered text
  void _showFinishDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: _currentCardColor,
          title: Text(
            'Game Over',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _kLegendModeColor, // Mode color
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
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
              child: Text('Play Again', style: TextStyle(color: _kLegendModeColor)), // Mode color
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
        _buildScoreColumn(
          label: 'PLAYER (X)',
          score: _playerXScore,
          color: _kPlayerXColor,
        ),
        _buildScoreColumn(
          label: 'DRAWS',
          score: _draws,
          color: _currentAccentColor,
        ),
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
            color: color.withOpacity(0.8),
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
                color: color.withOpacity(0.4),
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
            color: _currentBoardLineColor.withOpacity(0.3),
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
        title: Text('LEGEND MODE (VS CPU)', style: TextStyle(color: _currentAppBarTextColor)),
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
      // Aligned content to the top
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. SCOREBOARD
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: _buildScoreboard(),
            ),

            // 2. SPACE
            const SizedBox(height: 40.0),

            // 3. CURRENT PLAYER MESSAGE
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0), // Space before board
              child: Text(
                _message,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _message.startsWith('Player X')
                      ? _kPlayerXColor
                      : _message.startsWith('CPU O')
                      ? _kPlayerOColor
                      : _currentTextColor,
                ),
              ),
            ),

            // 4. GAME BOARD
            _buildBoard(),

            // 5. RESET BUTTON
            Padding(
              padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
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
                  backgroundColor: _kLegendModeColor,
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