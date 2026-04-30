import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'animated_widgets.dart';

const Color _kDarkAccentColor = Color(0xFF00BCD4);
const Color _kDarkBackgroundColor = Color(0xFF0F172A);
const Color _kDarkCardColor = Color(0xFF1E293B);
const Color _kDarkTextColor = Colors.white;

const Color _kLightAccentColor = Color(0xFF00BCD4);
const Color _kLightBackgroundColor = Color(0xFFF0F4F8);
const Color _kLightCardColor = Colors.white;
const Color _kLightTextColor = Color(0xFF1E293B);

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal() {
    _initPreferences();
  }

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _soundPlayer = AudioPlayer();

  // State
  bool _isSoundOn = true;
  bool _isMusicOn = true;
  bool _isVibrationOn = true;

  // Persistence keys
  static const String _kSoundKey = 'isSoundOn';
  static const String _kMusicKey = 'isMusicOn';
  static const String _kVibrationKey = 'isVibrationOn';

  // Getter methods
  bool get isSoundOn => _isSoundOn;
  bool get isMusicOn => _isMusicOn;
  bool get isVibrationOn => _isVibrationOn;

  Future<void> _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load state, defaulting to true if not found
    _isSoundOn = prefs.getBool(_kSoundKey) ?? true;
    _isMusicOn = prefs.getBool(_kMusicKey) ?? true;
    _isVibrationOn = prefs.getBool(_kVibrationKey) ?? true;

    // Apply music state immediately (must be async)
    if (_isMusicOn) {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('bg_music.mp3'));
    }
  }

  Future<void> setMusicEnabled(bool isEnabled) async {
    _isMusicOn = isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMusicKey, isEnabled);

    if (_isMusicOn) {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('bg_music.mp3'));
    } else {
      await _musicPlayer.pause();
    }
  }

  Future<void> setSoundEnabled(bool isEnabled) async {
    _isSoundOn = isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSoundKey, isEnabled);

    // Play a tap sound immediately if enabled to confirm setting change
    if (_isSoundOn) {
      await playTapSound();
    }
  }

  void setVibrationEnabled(bool isEnabled) async {
    _isVibrationOn = isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kVibrationKey, isEnabled); // SAVE STATE

    if (_isVibrationOn) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> playTapSound() async {
    if (_isSoundOn) {
      await _soundPlayer.stop();
      // NOTE: Ensure 'tap_sound.mp3' is available in assets
      await _soundPlayer.play(AssetSource('tap_sound.mp3'), volume: 0.5);
    }
  }
}

class Settings extends StatefulWidget {
  final bool isDarkTheme;
  final Function(bool) onThemeChanged;
  const Settings({super.key, required this.isDarkTheme, required this.onThemeChanged});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final SoundManager _soundManager = SoundManager();

  late bool _isSoundOn;
  late bool _isMusicOn;
  late bool _isVibrationOn;
  late bool _isDarkTheme;

  Color get _currentAccentColor => widget.isDarkTheme ? _kDarkAccentColor : _kLightAccentColor;
  Color get _currentBackgroundColor => widget.isDarkTheme ? _kDarkBackgroundColor : _kLightBackgroundColor;
  Color get _currentAppBarTextColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;
  Color get _currentTextColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;
  Color get _currentCardColor => widget.isDarkTheme ? _kDarkCardColor : _kLightCardColor;

  @override
  void initState() {
    super.initState();
    _isSoundOn = _soundManager.isSoundOn;
    _isMusicOn = _soundManager.isMusicOn;
    _isVibrationOn = _soundManager.isVibrationOn;
    _isDarkTheme = widget.isDarkTheme;
  }

  void _setThemeEnabled(bool isDark) async {
    setState(() {
      _isDarkTheme = isDark;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
    widget.onThemeChanged(isDark);
  }

  // --- NEW: Helper to group audio toggles and fix "unused field" warnings ---
  List<Widget> _audioToggles(bool isSmallScreen) {
    return [
      _buildToggleTile(
        'Sound Effects',
        Icons.volume_up,
        _isSoundOn,
            (value) {
          setState(() => _isSoundOn = value);
          _soundManager.setSoundEnabled(value);
        },
        isSmallScreen
      ),
      _buildToggleTile(
        'Background Music',
        Icons.music_note,
        _isMusicOn,
            (value) {
          setState(() => _isMusicOn = value);
          _soundManager.setMusicEnabled(value);
        },
        isSmallScreen
      ),
      _buildToggleTile(
        'Haptic Feedback',
        Icons.vibration,
        _isVibrationOn,
            (value) {
          setState(() => _isVibrationOn = value);
          _soundManager.setVibrationEnabled(value);
        },
        isSmallScreen
      ),
    ];
  }

  Widget _buildHeader(String title, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isSmallScreen ? 18 : 22,
          fontWeight: FontWeight.w900,
          color: _currentAccentColor,
          letterSpacing: 1.1,
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
        title: Text('Settings',
            style: TextStyle(color: _currentAppBarTextColor, fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 20 : 24)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _currentAppBarTextColor),
      ),
      body: LayoutBuilder(
          builder: (context, constraints) {
            bool isLargeScreen = constraints.maxWidth >= 800;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 40.0 : (isSmallScreen ? 8.0 : 12.0),
                  vertical: isSmallScreen ? 12.0 : 20.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                    decoration: BoxDecoration(
                      color: _currentCardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(20),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StaggeredEntrance(
                          delay: const Duration(milliseconds: 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader('Appearance', isSmallScreen),
                              _buildToggleTile(
                                  'Dark Theme',
                                  Icons.dark_mode,
                                  _isDarkTheme,
                                      (value) => _setThemeEnabled(value),
                                  isSmallScreen
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 30),
                        StaggeredEntrance(
                          delay: const Duration(milliseconds: 200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader('Audio & Haptics', isSmallScreen),
                              isLargeScreen
                                  ? GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                childAspectRatio: 4,
                                crossAxisSpacing: 20,
                                children: _audioToggles(isSmallScreen),
                              )
                                  : Column(children: _audioToggles(isSmallScreen)),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 30),
                        StaggeredEntrance(
                          delay: const Duration(milliseconds: 300),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader('About Game', isSmallScreen),
                              Text(
                                'Tic-Tac-Toe is the classic game of Xs and Os against a friend or four unique CPU difficulties, including the unbeatable AI.',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  height: 1.5,
                                  color: _currentTextColor.withAlpha(179),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  Widget _buildToggleTile(String title, IconData icon, bool value, Function(bool) onChanged, bool isSmallScreen) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: _currentAccentColor, size: isSmallScreen ? 20 : 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isSmallScreen ? 15 : 18,
          color: _currentTextColor,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: _currentAccentColor,
        trackOutlineColor: WidgetStateProperty.all(_currentAccentColor.withAlpha(128)),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _currentAccentColor.withAlpha(128);
          }
          return widget.isDarkTheme ? Colors.grey.shade700 : Colors.grey.shade300;
        }),
      ),
    );
  }
}