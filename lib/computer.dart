import 'package:flutter/material.dart';
import 'package:tictactoe/Modes/easyMode.dart';
import 'package:tictactoe/Modes/mediumMode.dart';
import 'package:tictactoe/Modes/hardMode.dart';

class ComputerScreen extends StatefulWidget {
  const ComputerScreen({Key? key}) : super(key: key);

  @override
  _ComputerScreenState createState() => _ComputerScreenState();
}

class _ComputerScreenState extends State<ComputerScreen> {
  Widget _buildModeButton(String text, Color color, Widget screen) {
    return SizedBox(
      width: 235,
      height: 90,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 28, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDF0F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B9DCF),
        title: const Text('Play vs CPU'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeButton('Easy', Colors.green.shade400, const EasyMode()),
            const SizedBox(height: 24),
            _buildModeButton('Medium', Colors.orange.shade400, const MediumMode()),
            const SizedBox(height: 24),
            _buildModeButton('Hard', Colors.red.shade400, const HardMode()),
          ],
        ),
      ),
    );
  }
}
