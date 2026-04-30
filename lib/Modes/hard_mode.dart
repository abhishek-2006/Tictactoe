import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import '../settings.dart';
import '../animated_widgets.dart';

const Color _kDarkBackgroundColor = Color(0xFF0F172A);
const Color _kDarkCardColor = Color(0xFF1E293B);
const Color _kDarkTextColor = Colors.white;

const Color _kLightBackgroundColor = Color(0xFFF0F4F8);
const Color _kLightCardColor = Colors.white;
const Color _kLightTextColor = Color(0xFF1E293B);

const Color _kPlayerXColor = Color(0xFFBF9F19); // Gold/Orange
const Color _kPlayerOColor = Color(0xFF1C89E3); // Blue
const Color _kHardModeColor = Color(0xFFF44336); // Red for Hard Mode

enum WinType { row, column, diagonalMain, diagonalAnti }

class HardMode extends StatefulWidget {
  final bool isDarkTheme;
  final Function(bool) onThemeChanged;
  const HardMode({super.key, required this.isDarkTheme, required this.onThemeChanged});

  @override
  HardModeState createState() => HardModeState();
}

class HardModeState extends State<HardMode> with TickerProviderStateMixin {
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
        if (_soundManager.isSoundOn) _soundManager.playTapSound();

        if (_checkWin(row, col)) {
          _gameFinished = true;
          _message = 'Player X Wins!';
          _playerXScore++;
          _lineController.forward();
          Future.delayed(const Duration(milliseconds: 400), () => _showFinishDialog(_message));
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
    }
  }

  void _runCpuTurn() {
    Timer(const Duration(milliseconds: 600), () {
      if (_gameFinished || !mounted) return;

      List<List<int>> emptyCells = [];
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          if (_board[r][c] == '') emptyCells.add([r, c]);
        }
      }

      if (emptyCells.isNotEmpty) {
        final random = Random();
        List<int> move;

        // Hard Mode Logic: 80% chance of optimal move, 20% random
        if (random.nextDouble() < 0.8) {
          move = _findOptimalMove();
        } else {
          move = emptyCells[random.nextInt(emptyCells.length)];
        }

        setState(() {
          _board[move[0]][move[1]] = 'O';
          if (_soundManager.isSoundOn) _soundManager.playTapSound();

          if (_checkWin(move[0], move[1])) {
            _gameFinished = true;
            _message = 'CPU Wins!';
            _cpuOScore++;
            _lineController.forward();
            Future.delayed(const Duration(milliseconds: 400), () => _showFinishDialog(_message));
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
      }
    });
  }

  List<int> _findOptimalMove() {
    // 1. Check for immediate winning move for 'O'
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (_board[r][c] == '') {
          _board[r][c] = 'O';
          if (_quickCheck(r, c)) { _board[r][c] = ''; return [r, c]; }
          _board[r][c] = '';
        }
      }
    }
    // 2. Block immediate winning move for 'X'
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (_board[r][c] == '') {
          _board[r][c] = 'X';
          if (_quickCheck(r, c)) { _board[r][c] = ''; return [r, c]; }
          _board[r][c] = '';
        }
      }
    }
    // 3. Take Center
    if (_board[1][1] == '') return [1, 1];

    // 4. Take Corners (Strategic for Hard mode)
    List<List<int>> corners = [[0, 0], [0, 2], [2, 0], [2, 2]];
    corners.shuffle();
    for (var corner in corners) {
      if (_board[corner[0]][corner[1]] == '') return corner;
    }

    // 5. Fallback: random empty cell
    List<List<int>> empty = [];
    for(int r=0; r<3; r++) {
      for (int c = 0; c < 3; c++) {
        if (_board[r][c] == '') {
          empty.add([r, c]);
        }
      }
    }
    return empty[Random().nextInt(empty.length)];
  }

  bool _quickCheck(int row, int col) {
    final p = _board[row][col];
    if (_board[row][0] == p && _board[row][1] == p && _board[row][2] == p) return true;
    if (_board[0][col] == p && _board[1][col] == p && _board[2][col] == p) return true;
    if (row == col && _board[0][0] == p && _board[1][1] == p && _board[2][2] == p) return true;
    if (row + col == 2 && _board[0][2] == p && _board[1][1] == p && _board[2][0] == p) return true;
    return false;
  }

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
        title: const Text('Game Over', textAlign: TextAlign.center, style: TextStyle(color: _kHardModeColor, fontWeight: FontWeight.bold)),
        content: Text(message, textAlign: TextAlign.center, style: TextStyle(color: _currentTextColor, fontSize: 18)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
              if (_soundManager.isVibrationOn) HapticFeedback.mediumImpact();
            },
            child: const Text('Play Again', style: TextStyle(color: _kHardModeColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboard(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScoreColumn(label: 'PLAYER (X)', score: _playerXScore, color: _kPlayerXColor, isSmallScreen: isSmallScreen),
        _buildScoreColumn(label: 'DRAWS', score: _draws, color: _isDark ? Colors.cyan : Colors.blue, isSmallScreen: isSmallScreen),
        _buildScoreColumn(label: 'CPU (O)', score: _cpuOScore, color: _kPlayerOColor, isSmallScreen: isSmallScreen),
      ],
    );
  }

  Widget _buildScoreColumn({required String label, required int score, required Color color, required bool isSmallScreen}) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: isSmallScreen ? 12 : 16, fontWeight: FontWeight.w600, color: color.withAlpha(204))),
        const SizedBox(height: 4),
        Text('$score', style: TextStyle(fontSize: isSmallScreen ? 28 : 36, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildBoard(bool isSmallScreen) {
    final double boardSize = isSmallScreen ? 280 : 330;
    const double lineThickness = 3.0;
    final double cellSize = (boardSize - (2 * lineThickness)) / 3;

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
                  size: Size(boardSize, boardSize),
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
          child: AnimatedMark(
            mark: _board[row][col],
            playerXColor: _kPlayerXColor,
            playerOColor: _kPlayerOColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 370;

    return Scaffold(
      backgroundColor: _currentBackgroundColor,
      appBar: AppBar(
        title: Text('HARD MODE (VS CPU)', style: TextStyle(color: _currentAppBarTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _currentAppBarTextColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, AdvancedPageTransition(page: Settings(isDarkTheme: _isDark, onThemeChanged: widget.onThemeChanged,))),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: isSmallScreen ? 20.0 : 40.0),
              StaggeredEntrance(delay: const Duration(milliseconds: 100), child: _buildScoreboard(isSmallScreen)),
              SizedBox(height: isSmallScreen ? 20.0 : 40.0),
              StaggeredEntrance(
                delay: const Duration(milliseconds: 200),
                child: PulsingText(
                  text: _message,
                  style: TextStyle(fontSize: isSmallScreen ? 22 : 28, fontWeight: FontWeight.bold, color: _message.startsWith('Player X') ? _kPlayerXColor : _message.startsWith('CPU') ? _kPlayerOColor : _currentTextColor)
                ),
              ),
              SizedBox(height: isSmallScreen ? 20.0 : 30.0),
              StaggeredEntrance(delay: const Duration(milliseconds: 300), child: _buildBoard(isSmallScreen)),
              SizedBox(height: isSmallScreen ? 20.0 : 40.0),
              StaggeredEntrance(
                delay: const Duration(milliseconds: 400),
                child: ElasticBouncingWidget(
                onTap: _resetGame,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 40, vertical: isSmallScreen ? 10 : 15),
                  decoration: const ShapeDecoration(
                    color: _kHardModeColor,
                    shape: StadiumBorder(),
                    shadows: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: isSmallScreen ? 22 : 24),
                      const SizedBox(width: 8),
                      Text('New Game', style: TextStyle(fontSize: isSmallScreen ? 16 : 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
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