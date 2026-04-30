import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'computer.dart';
import 'player.dart';
import 'settings.dart';
import 'animated_widgets.dart';

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
  final bool isDarkTheme;
  final Function(bool) onThemeChanged;

  const TicTacToeMenu({super.key, required this.isDarkTheme, required this.onThemeChanged});

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
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _currentAccentColor => widget.isDarkTheme ? _kDarkAccentColor : _kLightAccentColor;
  Color get _currentCardColor => widget.isDarkTheme ? _kDarkCardColor : _kLightCardColor;
  Color get _currentTextColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;
  Color get _currentSubtitleColor => widget.isDarkTheme ? Colors.white70 : Colors.black54;
  Color get _currentShadowColor => widget.isDarkTheme ? Colors.black.withAlpha(123) : Colors.grey.withAlpha(128);
  Color get _currentSettingsIconColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;


  Widget _buildHeader(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(
          top: isSmallScreen ? 10.0 : 20.0, 
          left: 16.0, 
          right: 16.0, 
          bottom: isSmallScreen ? 10.0 : 20.0),
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
              widget.onThemeChanged(value);
              if (_soundManager.isVibrationOn) {
                HapticFeedback.selectionClick();
              }
            },
            activeThumbColor: _kDarkAccentColor,
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
                AdvancedPageTransition(page: Settings(
                  isDarkTheme: widget.isDarkTheme,
                  onThemeChanged: widget.onThemeChanged,
                )),
              );
            },
            splashRadius: 28.0,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isSmallScreen) {
    return StaggeredEntrance(
      delay: const Duration(milliseconds: 300),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 20.0, 
          top: isSmallScreen ? 60.0 : 120.0,
        ),
        child: Column(
          children: [
            Text(
              'Made By',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: _currentSubtitleColor.withAlpha(180),
                fontWeight: FontWeight.w400,
                letterSpacing: 1.1,
              ),
            ),
            _buildBrandingText('Abhishek Shah'),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Destacy',
        fontSize: 20,
        color: _currentAccentColor.withAlpha(204),
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _buildAdaptiveButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required double height,
    required double iconSize,
    required double fontSize,
    required bool isSmall,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 6.0 : 12.0),
      child: ElasticBouncingWidget(
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
          height: height,
          decoration: BoxDecoration(
            color: _currentCardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _currentAccentColor.withAlpha(100), width: 1.5),
            boxShadow: [
              // Main shadow for depth
              BoxShadow(
                color: _currentShadowColor,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              // Subtle glow effect
              BoxShadow(
                color: _currentAccentColor.withAlpha(77),
                blurRadius: 8,
                spreadRadius: -2,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: isSmall ? 10 : 20),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Icon(
                    icon,
                    size: iconSize,
                    color: Color.lerp(_currentAccentColor.withAlpha(179), _currentAccentColor, _controller.value),
                  );
                },
              ),
              SizedBox(width: isSmall ? 10 : 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        color: _currentTextColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: isSmall ? 2 : 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isSmall ? 12 : 14,
                        color: _currentSubtitleColor,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // DETECT SCREEN SIZE
              final double screenWidth = constraints.maxWidth;
              final bool isSmallScreen = screenWidth < 370; // Threshold for J7 Prime style devices
              
              // Dynamic sizes based on screen
              final double titleSize = isSmallScreen ? 44 : 64;
              final double buttonHeight = isSmallScreen ? 90 : 120;
              final double iconSize = isSmallScreen ? 32 : 48;
              final double fontSizeTitle = isSmallScreen ? 18 : 24;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // 1. Header (Settings)
                        _buildHeader(isSmallScreen),

                        // 2. Title Section
                        StaggeredEntrance(
                          delay: const Duration(milliseconds: 100),
                          child: Column(
                            children: [
                              Text(
                                'Tic Tac Toe',
                                style: TextStyle(
                                  fontFamily: 'Destacy',
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w900,
                                  color: _currentAccentColor,
                                  letterSpacing: 3.0,
                                  shadows: [
                                    BoxShadow(
                                      color: _currentAccentColor.withAlpha(102),
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
                                  fontSize: isSmallScreen ? 14 : 18,
                                  color: _currentSubtitleColor,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 2),

                        // 3. Menu Buttons
                        StaggeredEntrance(
                          delay: const Duration(milliseconds: 200),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Column(
                                  children: [
                                    _buildAdaptiveButton(
                                      icon: Icons.computer,
                                      title: 'VS COMPUTER',
                                      subtitle: 'Play against an intelligent computer opponent',
                                      height: buttonHeight,
                                      iconSize: iconSize,
                                      fontSize: fontSizeTitle,
                                      isSmall: isSmallScreen,
                                      onTap: () {
                                        FirebaseAnalytics.instance.logEvent(
                                          name: "select_mode",
                                          parameters: {"mode": "ai"},
                                        );
                                        Navigator.push(context, AdvancedPageTransition(page: ComputerScreen(
                                          isDarkTheme: widget.isDarkTheme,
                                          onThemeChanged: widget.onThemeChanged,
                                        )));
                                      },
                                    ),
                                    _buildAdaptiveButton(
                                      icon: Icons.people_alt,
                                      title: 'VS FRIEND',
                                      subtitle: 'Local two-player mode on a single device',
                                      height: buttonHeight,
                                      iconSize: iconSize,
                                      fontSize: fontSizeTitle,
                                      isSmall: isSmallScreen,
                                      onTap: () {
                                        FirebaseAnalytics.instance.logEvent(
                                          name: "select_mode",
                                          parameters: {"mode": "pvp"},
                                        );
                                        Navigator.push(context, AdvancedPageTransition(page: PlayerScreen(
                                          isDarkTheme: widget.isDarkTheme,
                                          onThemeChanged: widget.onThemeChanged,
                                        )));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),

                        // 4. Footer
                        _buildFooter(isSmallScreen),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
