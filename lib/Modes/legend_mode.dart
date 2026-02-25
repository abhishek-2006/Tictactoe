import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import '../settings.dart';

const Color _kDarkBackgroundColor = Color(0xFF0F172A);
const Color _kDarkCardColor = Color(0xFF1E293B);
const Color _kDarkTextColor = Colors.white;

const Color _kLightBackgroundColor = Color(0xFFF0F4F8);
const Color _kLightCardColor = Colors.white;
const Color _kLightTextColor = Color(0xFF1E293B);

const Color _kPlayerXColor = Color(0xFFBF9F19); // Gold/Orange
const Color _kPlayerOColor = Color(0xFF1C89E3); // Blue
const Color _kLegendModeColor = Color(0xFF673AB7); // Purple for Legend Mode

enum WinType { row, column, diagonalMain, diagonalAnti }

class LegendMode extends StatefulWidget {
  final bool isDarkTheme;
  final Function(bool) onThemeChanged;
  const LegendMode({super.key, required this.isDarkTheme, required this.onThemeChanged});

  @override
  LegendModeState createState() => LegendModeState();
}

class LegendModeState extends State<LegendMode> with TickerProviderStateMixin {
  // Game State
  List<List<String>> _board = List.generate(3, (_) => List.generate(3, (_) => ''));
  String _currentPlayer = 'X';
  bool _gameFinished = false;
  String _message = 'Player X\'s Turn';

  WinType? _winType;
  int _winIndex = -1;
  Color? _winningLineColor;

  int _playerXScore = 0;
  int _cpuOScore = 0;
  int _draws = 0;

  late AnimationController _lineController;
  late Animation<double> _lineAnimation;
  final SoundManager _soundManager = SoundManager();

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // Dynamic Color Getters
  Color get _currentBackgroundColor => _isDark ? _kDarkBackgroundColor : _kLightBackgroundColor;
  Color get _currentCardColor => _isDark ? _kDarkCardColor : _kLightCardColor;
  Color get _currentAppBarTextColor => _isDark ? _kDarkTextColor : _kLightTextColor;
  Color get _currentTextColor => _isDark ? _kDarkTextColor : _kLightTextColor;
  Color get _currentBoardLineColor => _isDark ? _kDarkTextColor.withAlpha(128) : _kLightTextColor.withAlpha(128);

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _lineAnimation = CurvedAnimation(parent: _lineController, curve: Curves.easeOutCubic);
    _resetGame();
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  void _handleTap(int row, int col) {
    if (_board[row][col] == '' && !_gameFinished && _currentPlayer == 'X') {
      HapticFeedback.lightImpact();
      setState(() {
        _board[row][col] = 'X';
        if (_soundManager.isSoundOn) _soundManager.playTapSound(); // Using SoundManager method

        if (_checkWin(row, col)) {
          _gameFinished = true;
          _message = 'Player X Wins!';
          _playerXScore++;
          _lineController.forward();
          Future.delayed(const Duration(milliseconds: 600), () => _showFinishDialog(_message));
        } else if (_checkDraw()) {
          _gameFinished = true;
          _message = 'It\'s a Draw!';
          _draws++;
          _showFinishDialog(_message);
        } else {
          _currentPlayer = 'O';
          _message = 'CPU Thinking...';
          _runCpuTurn();
        }
      });
    }
  }

  void _runCpuTurn() {
    Timer(const Duration(milliseconds: 800), () {
      if (_gameFinished || !mounted) return;

      // Legend Mode Logic: Always 100% optimal (Minimax)
      List<int> move = _getBestMove();

      setState(() {
        _board[move[0]][move[1]] = 'O';
        if (_soundManager.isSoundOn) _soundManager.playTapSound();

        if (_checkWin(move[0], move[1])) {
          _gameFinished = true;
          _message = 'CPU Wins!';
          _cpuOScore++;
          _lineController.forward();
          Future.delayed(const Duration(milliseconds: 600), () => _showFinishDialog(_message));
        } else if (_checkDraw()) {
          _gameFinished = true;
          _message = 'It\'s a Draw!';
          _draws++;
          _showFinishDialog(_message);
        } else {
          _currentPlayer = 'X';
          _message = 'Player X\'s Turn';
        }
      });
    });
  }

  // --- MINIMAX AI LOGIC (Unbeatable) ---

  List<int> _getBestMove() {
    int bestScore = -1000;
    List<int> move = [-1, -1];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_board[i][j] == '') {
          _board[i][j] = 'O';
          int score = _minimax(_board, 0, false);
          _board[i][j] = '';
          if (score > bestScore) {
            bestScore = score;
            move = [i, j];
          }
        }
      }
    }
    return move;
  }

  int _minimax(List<List<String>> board, int depth, bool isMaximizing) {
    String? res = _evaluateBoard();
    if (res == 'O') return 10 - depth;
    if (res == 'X') return depth - 10;
    if (_checkDraw()) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j] == '') {
            board[i][j] = 'O';
            bestScore = max(bestScore, _minimax(board, depth + 1, false));
            board[i][j] = '';
          }
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (board[i][j] == '') {
            board[i][j] = 'X';
            bestScore = min(bestScore, _minimax(board, depth + 1, true));
            board[i][j] = '';
          }
        }
      }
      return bestScore;
    }
  }

  String? _evaluateBoard() {
    // Check rows, cols, diagonals and return winner 'X', 'O' or null
    for (int i = 0; i < 3; i++) {
      if (_board[i][0] != '' && _board[i][0] == _board[i][1] && _board[i][0] == _board[i][2]) return _board[i][0];
      if (_board[0][i] != '' && _board[0][i] == _board[1][i] && _board[0][i] == _board[2][i]) return _board[0][i];
    }
    if (_board[0][0] != '' && _board[0][0] == _board[1][1] && _board[0][0] == _board[2][2]) return _board[0][0];
    if (_board[0][2] != '' && _board[0][2] == _board[1][1] && _board[0][2] == _board[2][0]) return _board[0][2];
    return null;
  }

  // --- END AI LOGIC ---

  bool _checkWin(int row, int col) {
    final p = _board[row][col];
    _winningLineColor = (p == 'X') ? _kPlayerXColor : _kPlayerOColor;

    if (_board[row][0] == p && _board[row][1] == p && _board[row][2] == p) {
      _winType = WinType.row;
      _winIndex = row;
      return true;
    }
    if (_board[0][col] == p && _board[1][col] == p && _board[2][col] == p) {
      _winType = WinType.column;
      _winIndex = col;
      return true;
    }
    if (row == col && _board[0][0] == p && _board[1][1] == p && _board[2][2] == p) {
      _winType = WinType.diagonalMain;
      _winIndex = 0;
      return true;
    }
    if (row + col == 2 && _board[0][2] == p && _board[1][1] == p && _board[2][0] == p) {
      _winType = WinType.diagonalAnti;
      _winIndex = 0;
      return true;
    }
    return false;
  }

  bool _checkDraw() => _board.every((r) => r.every((c) => c != ''));

  void _resetGame() {
    setState(() {
      _board = List.generate(3, (_) => List.generate(3, (_) => ''));
      _currentPlayer = 'X';
      _gameFinished = false;
      _message = 'Player X\'s Turn';
      _winType = null;
      _winIndex = -1;
      _winningLineColor = null;
      _lineController.reset();
    });
  }

  void _showFinishDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        backgroundColor: _currentCardColor,
        title: const Text('Game Over', textAlign: TextAlign.center, style: TextStyle(color: _kLegendModeColor, fontWeight: FontWeight.bold)),
        content: Text(message, textAlign: TextAlign.center, style: TextStyle(color: _currentTextColor, fontSize: 18)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
              HapticFeedback.mediumImpact();
            },
            child: const Text('Play Again', style: TextStyle(color: _kLegendModeColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScoreColumn(label: 'PLAYER (X)', score: _playerXScore, color: _kPlayerXColor),
        _buildScoreColumn(label: 'DRAWS', score: _draws, color: _isDark ? Colors.cyan : Colors.blue),
        _buildScoreColumn(label: 'CPU (O)', score: _cpuOScore, color: _kPlayerOColor),
      ],
    );
  }

  Widget _buildScoreColumn({required String label, required int score, required Color color}) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color.withAlpha(204))),
        const SizedBox(height: 4),
        Text('$score', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildBoard() {
    const double boardSize = 330;
    const double lineThickness = 3.0;
    const double cellSize = (boardSize - (2 * lineThickness)) / 3;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        color: _currentCardColor,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: _currentBoardLineColor.withAlpha(77), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Stack(
        children: [
          Table(
            border: TableBorder.symmetric(inside: BorderSide(width: lineThickness, color: _currentBoardLineColor)),
            children: List.generate(3, (row) => TableRow(children: List.generate(3, (col) => _buildCell(row, col, cellSize)))),
          ),
          if (_winType != null && _winningLineColor != null)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _lineAnimation,
                builder: (context, child) => CustomPaint(
                  size: const Size(boardSize, boardSize),
                  painter: WinningLinePainter(
                    winType: _winType!,
                    index: _winIndex,
                    color: _winningLineColor!,
                    progress: _lineAnimation.value,
                  ),
                ),
              ),
            ),
        ],
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
        title: Text('LEGENDARY DUEL', style: TextStyle(color: _currentAppBarTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _currentAppBarTextColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Settings(isDarkTheme: _isDark, onThemeChanged: widget.onThemeChanged,))),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 40.0),
              _buildScoreboard(),
              const SizedBox(height: 40.0),
              Text(_message, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _message.startsWith('Player X') ? _kPlayerXColor : _message.startsWith('CPU') ? _kPlayerOColor : _currentTextColor)),
              const SizedBox(height: 30.0),
              _buildBoard(),
              const SizedBox(height: 40.0),
              ElevatedButton.icon(
                onPressed: _resetGame,
                icon: const Icon(Icons.refresh),
                label: const Text('New Game', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kLegendModeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: const StadiumBorder(),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}

class WinningLinePainter extends CustomPainter {
  final WinType winType;
  final int index;
  final Color color;
  final double progress;

  final Paint _linePaint;
  final Paint _glowPaint;

  WinningLinePainter({
    required this.winType,
    required this.index,
    required this.color,
    required this.progress,
  })  : _linePaint = Paint()
    ..color = color
    ..strokeWidth = 7
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke,
        _glowPaint = Paint()
          ..color = color.withAlpha(40)
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final cell = size.width / 3;
    final inset = size.width * 0.08;
    Offset start, end;

    switch (winType) {
      case WinType.row:
        start = Offset(inset, cell * index + cell / 2);
        end = Offset(size.width - inset, cell * index + cell / 2);
        break;
      case WinType.column:
        start = Offset(cell * index + cell / 2, inset);
        end = Offset(cell * index + cell / 2, size.height - inset);
        break;
      case WinType.diagonalMain:
        start = Offset(inset, inset);
        end = Offset(size.width - inset, size.height - inset);
        break;
      case WinType.diagonalAnti:
        start = Offset(size.width - inset, inset);
        end = Offset(inset, size.height - inset);
        break;
    }

    final animatedEnd = Offset.lerp(start, end, progress)!;
    canvas.drawLine(start, animatedEnd, _glowPaint);
    canvas.drawLine(start, animatedEnd, _linePaint);
  }

  @override
  bool shouldRepaint(covariant WinningLinePainter old) => old.progress != progress || old.color != color;
}