import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NEW IMPORT

// --- THEME PALETTES ---
const Color _kDarkAccentColor = Color(0xFF00BCD4);
const Color _kDarkBackgroundColor = Color(0xFF0F172A);
const Color _kDarkCardColor = Color(0xFF1E293B);
const Color _kDarkTextColor = Colors.white;

const Color _kLightAccentColor = Color(0xFF00BCD4);
const Color _kLightBackgroundColor = Color(0xFFF0F4F8);
const Color _kLightCardColor = Colors.white;
const Color _kLightTextColor = Color(0xFF1E293B);

class SoundManager {
  // Use a singleton pattern to ensure only one instance exists
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal() {
    // Initialize preferences when the singleton is first accessed
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

  // NEW: Method to load settings from SharedPreferences
  Future<void> _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load state, defaulting to true if not found
    _isSoundOn = prefs.getBool(_kSoundKey) ?? true;
    _isMusicOn = prefs.getBool(_kMusicKey) ?? true;
    _isVibrationOn = prefs.getBool(_kVibrationKey) ?? true;

    // Apply music state immediately (must be async)
    if (_isMusicOn) {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      // NOTE: Ensure 'bg_music.mp3' is available in assets
      await _musicPlayer.play(AssetSource('bg_music.mp3'));
    }
  }

  // MODIFIED: Setters now save the new state to SharedPreferences

  Future<void> setMusicEnabled(bool isEnabled) async {
    _isMusicOn = isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMusicKey, isEnabled); // SAVE STATE

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
    await prefs.setBool(_kSoundKey, isEnabled); // SAVE STATE

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
      HapticFeedback.lightImpact(); // Provide instant feedback
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
  final Function(bool) onThemeChanged; // NEW: Callback to notify ThemeWrapper
  const Settings({Key? key, required this.isDarkTheme, required this.onThemeChanged}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final SoundManager _soundManager = SoundManager();

  // Local state to track toggle values
  late bool _isSoundOn;
  late bool _isMusicOn;
  late bool _isVibrationOn;

  // New state for theme toggle to manage it locally
  late bool _isDarkTheme;

  // Dynamic Color Getters
  Color get _currentAccentColor => widget.isDarkTheme ? _kDarkAccentColor : _kLightAccentColor;
  Color get _currentBackgroundColor => widget.isDarkTheme ? _kDarkBackgroundColor : _kLightBackgroundColor;
  Color get _currentAppBarTextColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;
  Color get _currentTextColor => widget.isDarkTheme ? _kDarkTextColor : _kLightTextColor;

  @override
  void initState() {
    super.initState();
    // Initialize local states from SoundManager singleton and widget props
    _isSoundOn = _soundManager.isSoundOn;
    _isMusicOn = _soundManager.isMusicOn;
    _isVibrationOn = _soundManager.isVibrationOn;
    _isDarkTheme = widget.isDarkTheme;
  }

  // NEW: Method to save and apply the theme
  void _setThemeEnabled(bool isDark) async {
    setState(() {
      _isDarkTheme = isDark;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark); // SAVE THEME STATE
    widget.onThemeChanged(isDark); // Notify ThemeWrapper
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentBackgroundColor,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: _currentAppBarTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _currentAppBarTextColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- APPEARANCE ---
            Text(
              'Appearance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _currentTextColor,
              ),
            ),
            const SizedBox(height: 10),
            _buildToggleTile(
                'Dark Theme',
                Icons.dark_mode,
                _isDarkTheme,
                // Use the new save/notify function
                    (value) => _setThemeEnabled(value)
            ),
            const Divider(),

            const SizedBox(height: 30),

            // --- AUDIO & HAPTICS ---
            Text(
              'Audio & Haptics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _currentTextColor,
              ),
            ),
            const SizedBox(height: 10),

            // Sound Toggle
            _buildToggleTile(
              'Sound Effects',
              Icons.volume_up,
              _isSoundOn,
                  (value) {
                setState(() => _isSoundOn = value);
                _soundManager.setSoundEnabled(value);
              },
            ),
            const Divider(),

            // Music Toggle
            _buildToggleTile(
              'Background Music',
              Icons.music_note,
              _isMusicOn,
                  (value) {
                setState(() => _isMusicOn = value);
                _soundManager.setMusicEnabled(value);
              },
            ),
            const Divider(),

            // Vibration Toggle
            _buildToggleTile(
              'Haptic Feedback',
              Icons.vibration,
              _isVibrationOn,
                  (value) {
                setState(() => _isVibrationOn = value);
                _soundManager.setVibrationEnabled(value);
              },
            ),
            const Divider(),

            const SizedBox(height: 30),

            // --- ABOUT GAME ---
            Text(
              'About Game',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _currentTextColor,
              ),
            ),
            const SizedBox(height: 10),

            // About Text Content
            Text(
              'Tic-Tac-Toe is the classic game of Xs and Os against a friend or four unique CPU difficulties, including the unbeatable Legend AI.',
              style: TextStyle(
                fontSize: 16,
                color: _currentTextColor.withAlpha((0.7 * 255).round()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(String title, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: _currentAccentColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: _currentTextColor,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: _currentAccentColor,
        // Theming the track for better contrast
        trackOutlineColor: MaterialStateProperty.all(_currentAccentColor.withOpacity(0.5)),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _currentAccentColor.withOpacity(0.5);
          }
          return widget.isDarkTheme ? Colors.grey.shade700 : Colors.grey.shade300;
        }),
      ),
    );
  }
}
