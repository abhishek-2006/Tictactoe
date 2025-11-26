import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Modes/easy_mode.dart';
import 'Modes/hard_mode.dart';
import 'Modes/legend_mode.dart';
import 'Modes/medium_mode.dart';
import 'settings.dart';

// --- THEME PALETTES ---
const Color _kDarkAccentColor = Color(0xFF00BCD4);
const Color _kDarkBackgroundColor = Color(0xFF0F172A);
const Color _kDarkCardColor = Color(0xFF1E293B);
const Color _kDarkTextColor = Colors.white;

const Color _kLightAccentColor = Color(0xFF52D6FF);
const Color _kLightBackgroundColor = Color(0xFFF0F4F8);
const Color _kLightCardColor = Colors.white;
const Color _kLightTextColor = Color(0xFF1E293B);

// Mode-specific Colors
const Color _kEasyColor = Color(0xFF4CAF50);      // Green
const Color _kMediumColor = Color(0xFFFF9800);  // Orange
const Color _kHardColor = Color(0xFFF44336);      // Red
const Color _kLegendColor = Color(0xFF673AB7);    // Purple for Legend

class ComputerScreen extends StatefulWidget {
  final bool isDarkTheme;
  final Function(bool) onThemeChanged; // NEW PROP
  const ComputerScreen({super.key, required this.isDarkTheme, required this.onThemeChanged});

  @override
  ComputerScreenState createState() => ComputerScreenState();
}

class ComputerScreenState extends State<ComputerScreen> {
  final SoundManager _soundManager = SoundManager();

  // Dynamic Color Getters
  Color get _currentAccentColor => widget.isDarkTheme ? _kDarkAccentColor : _kLightAccentColor;
  Color get _currentAppBarTextColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;
  Color get _currentCardColor => widget.isDarkTheme ? _kDarkCardColor : _kLightCardColor;
  Color get _currentShadowColor => widget.isDarkTheme ? Colors.black.withAlpha(153) : Colors.grey.withAlpha(128);
  Color get _currentTextColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;


  Widget _buildInteractiveCard({
    required String text,
    required Color color,
    required Widget screen,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: GestureDetector(
        onTap: () {
          if (_soundManager.isVibrationOn) {
            HapticFeedback.mediumImpact();
          }
          if (_soundManager.isSoundOn) {
            _soundManager.playTapSound();
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: FractionallySizedBox(
          widthFactor: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: _currentCardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withAlpha(102), width: 2),
              boxShadow: [
                BoxShadow(
                  color: _currentShadowColor,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: color.withAlpha(51),
                  blurRadius: 4,
                  spreadRadius: -2,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: color,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getModeDescription(text),
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 16,
                            color: _currentTextColor.withAlpha(179),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    icon,
                    size: 50,
                    color: color.withAlpha(204),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getModeDescription(String mode) {
    switch (mode) {
      case 'EASY':
        return 'A gentle warm-up with predictable errors.';
      case 'MEDIUM':
        return 'A good challenge combining strategy and errors.';
      case 'HARD':
        return 'Mostly optimal, only minor slip-ups allowed.';
      case 'LEGEND':
        return 'Unbeatable. Can only result in a draw.';
      default:
        return '';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDarkTheme
                ? [_kDarkBackgroundColor, _kDarkCardColor]
                : [const Color(0xFFE5F5FF), _kLightBackgroundColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              title: Text(
                'PLAY VS CPU',
                style: TextStyle(
                  color: _currentAppBarTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              iconTheme: IconThemeData(color: _currentAppBarTextColor),

              // Custom leading widget to handle back button tap
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
                  icon: Icon(Icons.settings, color: _currentAccentColor,),
                  onPressed: () {
                    if (_soundManager.isVibrationOn) {
                      HapticFeedback.lightImpact();
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Settings(
                        isDarkTheme: widget.isDarkTheme,
                        onThemeChanged: widget.onThemeChanged, // PASS CALLBACK
                      )),
                    );
                  },
                ),
              ],
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // EASY MODE (40% Minimax)
                    _buildInteractiveCard(
                      text: 'EASY',
                      color: _kEasyColor,
                      screen: EasyMode(
                        isDarkTheme: widget.isDarkTheme,
                        onThemeChanged: widget.onThemeChanged, // PASS CALLBACK
                      ),
                      icon: Icons.grass,
                    ),
                    // MEDIUM MODE (60% Minimax)
                    _buildInteractiveCard(
                      text: 'MEDIUM',
                      color: _kMediumColor,
                      screen: MediumMode(
                        isDarkTheme: widget.isDarkTheme,
                        onThemeChanged: widget.onThemeChanged, // PASS CALLBACK
                      ),
                      icon: Icons.bolt,
                    ),
                    // HARD MODE (70% Minimax)
                    _buildInteractiveCard(
                      text: 'HARD',
                      color: _kHardColor,
                      screen: HardMode(
                        isDarkTheme: widget.isDarkTheme,
                        onThemeChanged: widget.onThemeChanged, // PASS CALLBACK
                      ),
                      icon: Icons.hardware,
                    ),
                    // LEGEND MODE (100% Minimax)
                    _buildInteractiveCard(
                      text: 'LEGEND',
                      color: _kLegendColor,
                      screen: LegendMode(
                        isDarkTheme: widget.isDarkTheme,
                        onThemeChanged: widget.onThemeChanged, // PASS CALLBACK
                      ),
                      icon: Icons.workspace_premium, // Crown/Premium Icon
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
