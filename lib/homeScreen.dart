import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'computer.dart';
import 'player.dart';
import 'settings.dart';

// --- THEME PALETTES ---
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

class TicTacToeMenu extends StatefulWidget {
  // NEW PROPS: Receive theme state and callback from ThemeWrapper
  final bool isDarkTheme;
  final Function(bool) onThemeChanged;

  const TicTacToeMenu({Key? key, required this.isDarkTheme, required this.onThemeChanged}) : super(key: key);

  @override
  State<TicTacToeMenu> createState() => _TicTacToeMenuState();
}

class _TicTacToeMenuState extends State<TicTacToeMenu> with SingleTickerProviderStateMixin {

  // Animation controller for the subtle glowing effect on the buttons
  late AnimationController _controller;
  final SoundManager _soundManager = SoundManager();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true); // Loop the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Dynamic Color Getters now use widget.isDarkTheme
  Color get _currentAccentColor => widget.isDarkTheme ? _kDarkAccentColor : _kLightAccentColor;
  Color get _currentBackgroundColor => widget.isDarkTheme ? _kDarkBackgroundColor : _kLightBackgroundColor;
  Color get _currentCardColor => widget.isDarkTheme ? _kDarkCardColor : _kLightCardColor;
  Color get _currentTextColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;
  Color get _currentSubtitleColor => widget.isDarkTheme ? Colors.white70 : Colors.black54;
  Color get _currentShadowColor => widget.isDarkTheme ? Colors.black.withOpacity(0.6) : Colors.grey.withOpacity(0.5);
  Color get _currentSettingsIconColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;


  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required double maxWidth,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: GestureDetector(
        onTap: () {
          if (_soundManager.isSoundOn) {
            _soundManager.playTapSound();
          }
          if (_soundManager.isVibrationOn) {
            HapticFeedback.lightImpact();
          }
          onTap();
        },
        child: Container(
          width: maxWidth,
          height: 120,
          decoration: BoxDecoration(
            color: _currentCardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              // Main shadow for depth
              BoxShadow(
                color: _currentShadowColor,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              // Subtle glow effect
              BoxShadow(
                color: _currentAccentColor.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: -2,
                offset: const Offset(0, 0),
              ),
            ],
            border: Border.all(color: _currentAccentColor.withOpacity(0.4), width: 1.5),
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              // Icon with animated glow
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Icon(
                    icon,
                    size: 48,
                    color: Color.lerp(_currentAccentColor.withOpacity(0.7), _currentAccentColor, _controller.value),
                  );
                },
              ),
              const SizedBox(width: 20),
              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: _currentTextColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 14,
                        color: _currentSubtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 20,
        color: _currentAccentColor.withOpacity(0.8),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth * 0.9;

          return Container(
            // Background Gradient
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDarkTheme
                    ? [_kDarkBackgroundColor, _kDarkCardColor]
                    : [const Color(0xFFE5F5FF), _kLightBackgroundColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // 1. Header (Settings & Theme Switch)
                Padding(
                  padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Theme Switch (Toggle between dark/light)
                      Icon(
                        widget.isDarkTheme ? Icons.nights_stay : Icons.wb_sunny,
                        color: _currentAccentColor,
                        size: 20,
                      ),
                      Switch(
                        value: widget.isDarkTheme,
                        onChanged: (value) {
                          // MODIFIED: Use the callback to update ThemeWrapper/main.dart
                          widget.onThemeChanged(value);
                          if (_soundManager.isVibrationOn) {
                            HapticFeedback.selectionClick();
                          }
                          // Saving is handled by settings.dart
                        },
                        activeColor: _kDarkAccentColor,
                        inactiveThumbColor: _kLightAccentColor,
                      ),
                      const SizedBox(width: 8),
                      // Settings Button
                      IconButton(
                        icon: Icon(Icons.settings, size: 28, color: _currentSettingsIconColor),
                        onPressed: () {
                          if (_soundManager.isVibrationOn) {
                            HapticFeedback.lightImpact();
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Settings(
                              isDarkTheme: widget.isDarkTheme,
                              onThemeChanged: widget.onThemeChanged, // PASS CALLBACK
                            )),
                          );
                        },
                        splashRadius: 28.0,
                      ),
                    ],
                  ),
                ),

                // 2. Title
                Text(
                  'Tic Tac Toe',
                  style: TextStyle(
                    fontFamily: 'Destacy', // Assuming a bold, custom font
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: _currentAccentColor,
                    letterSpacing: 3.0,
                    shadows: [
                      BoxShadow(
                        color: _currentAccentColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Ultimate Edition',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    color: _currentSubtitleColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                  ),
                ),

                // 3. Menu Buttons
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // VS COMPUTER
                          _buildMenuButton(
                            icon: Icons.computer,
                            title: 'VS CPU',
                            subtitle: 'Play against an intelligent computer opponent',
                            onTap: () {
                              // MODIFIED: Pass theme state and callback
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ComputerScreen(
                                isDarkTheme: widget.isDarkTheme,
                                onThemeChanged: widget.onThemeChanged,
                              )));
                            },
                            maxWidth: maxWidth,
                          ),
                          // VS FRIEND
                          _buildMenuButton(
                            icon: Icons.people_alt,
                            title: 'VS FRIEND',
                            subtitle: 'Local two-player mode on a single device',
                            onTap: () {
                              // MODIFIED: Pass theme state and callback
                              Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(
                                isDarkTheme: widget.isDarkTheme,
                                onThemeChanged: widget.onThemeChanged,
                              )));
                            },
                            maxWidth: maxWidth,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Footer Branding
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
                  child: Column(
                    children: [
                      Text(
                        'Designed By',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: _currentSubtitleColor,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.0,
                        ),
                      ),
                      _buildBrandingText('ABHISHEK SHAH'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
