import 'package:flutter/material.dart';
import 'package:tictactoe/homeScreen.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TicTacToeMenu()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              "assets/splash.png",
              height: 200,
              width: 200,
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
                    color: Colors.black87,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Abhishek Shah',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Destacy',
                    color: Color(0xFF2C64A7),
                    fontWeight: FontWeight.w600,
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
