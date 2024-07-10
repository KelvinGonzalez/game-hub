import 'package:flutter/material.dart';
import 'package:game_hub/model/game_manager.dart';
import 'package:game_hub/model/status.dart';

class GameEndAlert extends StatelessWidget {
  final WinStatus winStatus;

  const GameEndAlert({super.key, required this.winStatus});

  String getText() {
    switch (winStatus) {
      case WinStatus.win:
        return "You won!";
      case WinStatus.loss:
        return "You lost!";
      case WinStatus.draw:
        return "It's a draw!";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(getText()),
      actions: [
        TextButton(
            onPressed: () async {
              await GameManager.instance.leaveRoom();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("Leave")),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Play Again"))
      ],
    );
  }
}
