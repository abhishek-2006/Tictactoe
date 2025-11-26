import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/main.dart';

void main() {
  testWidgets('Tic Tac Toe smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TicTacToeApp());

    // Verify that we start with an empty board and no winner displayed.
    expect(find.text('Player X wins!'), findsNothing);
    expect(find.text('Player O wins!'), findsNothing);
    expect(find.text("It's a draw!"), findsNothing);

    // Tap on a few cells to simulate a game.
    await tester.tap(find.byType(GestureDetector).first); // Tap on the first cell
    await tester.pump(); // Rebuild the widget after the tap
    await tester.tap(find.byType(GestureDetector).at(4)); // Tap on the middle cell
    await tester.pump(); // Rebuild the widget after the tap

    // Verify the board displays correct markers after taps.
    expect(find.text('X'), findsOneWidget);
    expect(find.text('O'), findsOneWidget);

    // Add more tests as needed to cover different scenarios of your game.
  });
}
