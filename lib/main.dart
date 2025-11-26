import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThemeWrapper();
  }
}

class ThemeWrapper extends StatefulWidget {
  const ThemeWrapper({super.key});

  @override
  State<ThemeWrapper> createState() => _ThemeWrapperState();
}

class _ThemeWrapperState extends State<ThemeWrapper> {
  bool isDarkTheme = true; // Default to dark theme
  bool _isLoading = true; // State to manage loading prefs

  @override
  void initState() {
    super.initState();
    _loadThemePreference(); // Load theme on init
  }

  // Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    // Load state, defaulting to true (Dark Theme) if not found
    setState(() {
      isDarkTheme = prefs.getBool('isDarkTheme') ?? true;
      _isLoading = false;
    });
  }

  void toggleTheme(bool newValue) {
    // Update local state, the saving to SharedPreferences is handled in settings.dart
    setState(() {
      isDarkTheme = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a simple loading indicator while prefs are being read
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.cyan,
      ),

      // Pass the theme state and the toggle function to the splash screen
      home: SplashDecider(
        isDarkTheme: isDarkTheme,
        onThemeChanged: toggleTheme, // PASS CALLBACK
      ),
    );
  }
}

// 3. SplashDecider (Passes props to the next screen)
class SplashDecider extends StatefulWidget {
  final bool isDarkTheme;
  final Function(bool) onThemeChanged; // NEW PROP

  const SplashDecider({super.key, required this.isDarkTheme, required this.onThemeChanged});

  @override
  State<SplashDecider> createState() => SplashDeciderState();
}

class SplashDeciderState extends State<SplashDecider> {
  // State to control whether to show the splash screen or the main content
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // The core logic: Wait 3 seconds, then switch to the main menu
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      // Show the custom Flutter splash screen
      return FlutterSplashScreen(isDarkTheme: widget.isDarkTheme);
    } else {
      // Transition to the main menu (home_screen.dart)
      return TicTacToeMenu(
        isDarkTheme: widget.isDarkTheme, // PASS PROP
        onThemeChanged: widget.onThemeChanged, // PASS CALLBACK
      );
    }
  }
}

// 4. FlutterSplashScreen (Dynamic Theming)
class FlutterSplashScreen extends StatelessWidget {
  final bool isDarkTheme;

  const FlutterSplashScreen({super.key, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDarkTheme ? const Color(0xFF0F172A) : Colors.white;
    final Color textColor = isDarkTheme ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              "assets/splash.png",
              height: 150,
              width: 150,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Designed by',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    color: textColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const Text(
                  'Abhishek Shah',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    color: Color(0xFF2C64A7),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
