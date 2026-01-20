import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../settings.dart';

// --- THEME PALETTES (Copied for self-containment) ---
// Dark Theme Colors
const Color _kDarkAccentColor = Color(0xFF00BCD4);
const Color _kDarkBackgroundColor = Color(0xFF0F172A);
const Color _kDarkCardColor = Color(0xFF1E293B);
const Color _kDarkTextColor = Colors.white;

// Light Theme Colors
const Color _kLightAccentColor = Color(0xFF00BCD4);
const Color _kLightBackgroundColor = Color(0xFFF0F4F8);
const Color _kLightCardColor = Colors.white;
const Color _kLightTextColor = Color(0xFF1E293B);

// Player Colors (Constant for contrast regardless of theme)
const Color _kPlayerXColor = Color(0xFFBF9F19); // Gold
const Color _kPlayerOColor = Color(0xFF1C89E3); // Bright Blue

enum WinType { row, column, diagonalMain, diagonalAnti, }


class PlayerScreen extends StatefulWidget {
  final bool isDarkTheme;
  final Function(bool) onThemeChanged;
  const PlayerScreen({super.key, required this.isDarkTheme, required this.onThemeChanged});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  // Game State
  List<List<String>> _board = List.generate(3, (_) => List.filled(3, ''));
  String _currentPlayer = 'X';
  bool _gameFinished = false;
  String _message = 'Player X Turn';
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  WinType? _winType;
  int _winIndex = -1;


  // Score
  int _playerXScore = 0;
  int _playerOScore = 0;
  int _draws = 0;

  @override
  void initState() {
    super.initState();

    _lineController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300)
    );

    _lineAnimation = CurvedAnimation(
        parent: _lineController,
        curve: Curves.easeOutCubic
    );

    _resetGame();
  }

  // Dynamic Color Getters for the current screen
  Color get _currentAccentColor => widget.isDarkTheme ? _kDarkAccentColor : _kLightAccentColor;
  Color get _currentBackgroundColor => widget.isDarkTheme ? _kDarkBackgroundColor : _kLightBackgroundColor;
  Color get _currentCardColor => widget.isDarkTheme ? _kDarkCardColor : _kLightCardColor;
  Color get _currentTextColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;
  Color get _currentBoardLineColor => widget.isDarkTheme ? _kDarkTextColor.withAlpha(128) : _kLightTextColor.withAlpha(128);

  void _resetGame() {
    setState(() {
      _board = List.generate(3, (_) => List.filled(3, ''));
      _currentPlayer = 'X';
      _gameFinished = false;
      _message = 'Player X Turn';
      _winType = null;
      _winIndex = -1;
      _lineController.reset();
    });
  }

  void _handleTap(int row, int col) {
    if (_board[row][col] == '' && !_gameFinished) {
      HapticFeedback.lightImpact();
      setState(() {
        _board[row][col] = _currentPlayer;

        if (_checkWin(row, col)) {
          _gameFinished = true;
          _message = 'Player $_currentPlayer Wins!';
          _lineController.forward(from: 0);
          if (_currentPlayer == 'X') {
            _playerXScore++;
          } else {
            _playerOScore++;
          }
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            _showFinishDialog(_message, _currentPlayer);
          });
        } else if (_checkDraw()) {
          _gameFinished = true;
          _message = 'It\'s a Draw!';
          _draws++;
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            _showFinishDialog(_message, null);
          });
        } else {
          _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
          _message = 'Player $_currentPlayer Turn';
        }
      });
    } else if (_gameFinished) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        _showFinishDialog(_message, null);
      });
    }
  }

  bool _checkWin(int row, int col) {
    String player = _board[row][col];

    // Check Row
    if (_board[row].every((cell) => cell == player)) {
      _winType = WinType.row;
      _winIndex = row;
      return true;
    }

    // Check Column
    if (_board.every((r) => r[col] == player)) {
      _winType = WinType.column;
      _winIndex = col;
      return true;
    }

    // Check Main Diagonal (top-left to bottom-right)
    if (row == col && List.generate(3, (i) => _board[i][i]).every((cell) => cell == player)) {
      _winType = WinType.diagonalMain;
      _winIndex = 0;
      return true;
    }

    // Check Anti-Diagonal (top-right to bottom-left)
    if (row + col == 2 && List.generate(3, (i) => _board[i][2 - i]).every((cell) => cell == player)) {
      _winType = WinType.diagonalAnti;
      _winIndex = 2;
      return true;
    }

    return false;
  }

  bool _checkDraw() {
    return _board.every((row) => row.every((cell) => cell != ''));
  }

  void _showFinishDialog(String message, String? winner) {
    Color dialogColor = winner == 'X' ? _kPlayerXColor : winner == 'O' ? _kPlayerOColor : _currentAccentColor;

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
              color: dialogColor,
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
                HapticFeedback.mediumImpact();
              },
              child: Text('Play Again', style: TextStyle(color: dialogColor)),
            ),
          ],
        );
      },
    );
  }

  // --- UI Building Widgets ---

  Widget _buildScoreboard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Player X Score
        _buildScoreColumn(
          label: 'PLAYER X',
          score: _playerXScore,
          color: _kPlayerXColor,
        ),
        // Draws Score
        _buildScoreColumn(
          label: 'DRAWS',
          score: _draws,
          color: _currentAccentColor,
        ),
        // Player O Score
        _buildScoreColumn(
          label: 'PLAYER O',
          score: _playerOScore,
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
    // Corrected board size calculation to prevent line flow-out.
    const double boardSize = 330;
    const double lineThickness = 3.0;
    // Calculate cell size: (Total Size - Total Line Width) / Number of Cells
    const double cellSize = (boardSize - (2 * lineThickness)) / 3; // (330 - 6) / 3 = 108.0

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Stack(
        children: [
          Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            color: _currentCardColor,
            borderRadius: BorderRadius.circular(12),
            // Applying a subtle shadow for depth
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
                width: lineThickness,
                color: _currentBoardLineColor,
              ),
            ),
            children: List.generate(3, (row) {
              return TableRow(
                children: List.generate(3, (col) {
                  // Now passing the calculated cellSize
                  return _buildCell(row, col, cellSize);
                }),
              );
            }),
          ),
          ),

          // Winning line overlay
          if (_winType != null)
            AnimatedBuilder(
              animation: _lineController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(boardSize, boardSize),
                  painter: WinningLinePainter(
                    winType: _winType!,
                    index: _winIndex,
                    color: _currentPlayer == 'X'
                        ? _kPlayerXColor
                        : _kPlayerOColor,
                    progress: _lineAnimation.value,
                  ),
                );
              },
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
        title: Text('VS FRIEND', style: TextStyle(color: _currentTextColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _currentTextColor),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _currentTextColor),
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              HapticFeedback.lightImpact();
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              _buildScoreboard(),

              const SizedBox(height: 60.0),

              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Text(
                  _message,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _message.contains('X Turn') ? _kPlayerXColor : _message.contains('O Turn') ? _kPlayerOColor : _currentTextColor,
                  ),
                ),
              ),

              _buildBoard(),

              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _resetGame();
                  },
                  icon: const Icon(Icons.refresh, size: 28),
                  label: const Text('New Game', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentAccentColor,
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
      ),
    );
  }
}

class WinningLinePainter extends CustomPainter {
  final WinType winType;
  final int index;
  final Color color;
  final double progress;

  WinningLinePainter({
    required this.winType,
    required this.index,
    required this.color,
    required this.progress,
  });

  @override
  @override
  void paint(Canvas canvas, Size size) {
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

    final glowPaint = Paint()
      ..color = color.withAlpha(90)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, animatedEnd, glowPaint);
    canvas.drawLine(start, animatedEnd, linePaint);
  }

  @override
  bool shouldRepaint(covariant WinningLinePainter old) =>
      old.progress != progress;
}