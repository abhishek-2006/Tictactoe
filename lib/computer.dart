import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Modes/easy_mode.dart';
import 'Modes/hard_mode.dart';
import 'Modes/legend_mode.dart';
import 'Modes/medium_mode.dart';
import 'settings.dart';
import 'animated_widgets.dart';

const Color _kDarkAccentColor = Color(0xFF00BCD4);
const Color _kDarkBackgroundColor = Color(0xFF0F172A);
const Color _kDarkCardColor = Color(0xFF1E293B);
const Color _kDarkTextColor = Colors.white;

const Color _kLightAccentColor = Color(0xFF52D6FF);
const Color _kLightBackgroundColor = Color(0xFFF0F4F8);
const Color _kLightCardColor = Colors.white;
const Color _kLightTextColor = Color(0xFF1E293B);

const Color _kEasyColor = Color(0xFF4CAF50);
const Color _kMediumColor = Color(0xFFFF9800);
const Color _kHardColor = Color(0xFFF44336);
const Color _kLegendColor = Color(0xFF673AB7);

class ComputerScreen extends StatefulWidget {
  final bool isDarkTheme;
  final Function(bool) onThemeChanged;
  const ComputerScreen({super.key, required this.isDarkTheme, required this.onThemeChanged});

  @override
  ComputerScreenState createState() => ComputerScreenState();
}

class ComputerScreenState extends State<ComputerScreen> {
  final SoundManager _soundManager = SoundManager();

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
    bool isGridMode = false,
    bool isSmallScreen = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isGridMode ? 8.0 : (isSmallScreen ? 16.0 : 24.0),
          vertical: isGridMode ? 8.0 : 12.0
      ),
      child: ElasticBouncingWidget(
        onTap: () {
          if (_soundManager.isVibrationOn) HapticFeedback.mediumImpact();
          if (_soundManager.isSoundOn) _soundManager.playTapSound();
          Navigator.push(context, AdvancedPageTransition(page: screen));
        },
        child: Container(
          decoration: BoxDecoration(
            color: _currentCardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withAlpha(102), width: 2),
            boxShadow: [
              BoxShadow(color: _currentShadowColor, blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen && !isGridMode ? 16.0 : 20.0),
            child: isGridMode
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color.withAlpha(204)),
                const SizedBox(height: 12),
                Text(text, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
                const SizedBox(height: 4),
                Text(_getModeDescription(text), textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: _currentTextColor.withAlpha(179))),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text, style: TextStyle(fontSize: isSmallScreen ? 24 : 32, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(_getModeDescription(text), style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: _currentTextColor.withAlpha(179))),
                    ],
                  ),
                ),
                Icon(icon, size: isSmallScreen ? 40 : 50, color: color.withAlpha(204)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getModeDescription(String mode) {
    switch (mode) {
      case 'EASY': return 'An easy opponent for beginners.';
      case 'MEDIUM': return 'A balanced challenge for casual players.';
      case 'HARD': return 'A tough opponent for experienced players.';
      case 'LEGEND': return 'A legendary challenge for the best of the best.';
      default: return '';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isSmallScreen = constraints.maxWidth < 370;
            bool isMobile = constraints.maxWidth <= 600;
            bool isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 1000;
            bool isDesktop = constraints.maxWidth > 1000;

            return Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage('assets/splash.png'),
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(width: 12),
                      Text('PLAY VS CPU',
                          style: TextStyle(
                              color: _currentAppBarTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 20 : 24)),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.settings, color: _currentAccentColor),
                      onPressed: () => Navigator.push(
                          context,
                          AdvancedPageTransition(
                              page: Settings(
                            isDarkTheme: widget.isDarkTheme,
                            onThemeChanged: widget.onThemeChanged
                          )
                        )
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? double.infinity : 1000,
                      ),
                      child: CustomScrollView(
                        // shrinkWrap allows the content to sit in the center of the screen
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          if (isMobile)
                            SliverList(
                              delegate: SliverChildListDelegate([
                                _buildCards(false, isSmallScreen),
                              ]),
                            )
                          else if (isTablet)
                              SliverPadding(
                                padding: const EdgeInsets.all(32),
                                sliver: SliverGrid(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isDesktop ? 2 : 2,
                                    childAspectRatio: 1.5,
                                    mainAxisSpacing: 40,
                                    crossAxisSpacing: 40,
                                  ),
                                  delegate: SliverChildListDelegate(_buildGridCards(true, isSmallScreen)),
                                ),
                              )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.all(80.0),
                              sliver: SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop ? 2 : 2,
                                  childAspectRatio: 1.5,
                                  mainAxisSpacing: 40,
                                  crossAxisSpacing: 40,
                                ),
                                delegate: SliverChildListDelegate(_buildGridCards(true, isSmallScreen)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper for Column (Mobile)
  Widget _buildCards(bool isGrid, bool isSmallScreen) {
    return Column(
      children: _buildGridCards(isGrid, isSmallScreen),
    );
  }

  // Common list of cards
  List<Widget> _buildGridCards(bool isGrid, bool isSmallScreen) {
    return [
      StaggeredEntrance(delay: const Duration(milliseconds: 100), child: _buildInteractiveCard(text: 'EASY', color: _kEasyColor, icon: Icons.grass, screen: EasyMode(isDarkTheme: widget.isDarkTheme, onThemeChanged: widget.onThemeChanged), isGridMode: isGrid, isSmallScreen: isSmallScreen)),
      StaggeredEntrance(delay: const Duration(milliseconds: 200), child: _buildInteractiveCard(text: 'MEDIUM', color: _kMediumColor, icon: Icons.bolt, screen: MediumMode(isDarkTheme: widget.isDarkTheme, onThemeChanged: widget.onThemeChanged), isGridMode: isGrid, isSmallScreen: isSmallScreen)),
      StaggeredEntrance(delay: const Duration(milliseconds: 300), child: _buildInteractiveCard(text: 'HARD', color: _kHardColor, icon: Icons.hardware, screen: HardMode(isDarkTheme: widget.isDarkTheme, onThemeChanged: widget.onThemeChanged), isGridMode: isGrid, isSmallScreen: isSmallScreen)),
      StaggeredEntrance(delay: const Duration(milliseconds: 400), child: _buildInteractiveCard(text: 'LEGEND', color: _kLegendColor, icon: Icons.workspace_premium, screen: LegendMode(isDarkTheme: widget.isDarkTheme, onThemeChanged: widget.onThemeChanged), isGridMode: isGrid, isSmallScreen: isSmallScreen)),
    ];
  }
}