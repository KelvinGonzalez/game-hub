import 'package:flutter/material.dart';
import 'package:game_hub/model/game_manager.dart';
import 'package:game_hub/model/room.dart';

class RockPaperScissorsPage extends StatefulWidget {
  const RockPaperScissorsPage({super.key});

  @override
  State<RockPaperScissorsPage> createState() => _RockPaperScissorsPageState();
}

class _RockPaperScissorsPageState extends State<RockPaperScissorsPage> {
  late GameManager gameManager;
  List<String> choices = ["Rock", "Paper", "Scissors"];
  final choiceToEmoji = {"Rock": "🪨", "Paper": "📄", "Scissors": "✂"};
  bool _moveEnqueued = false;

  @override
  void initState() {
    super.initState();
    gameManager = GameManager.instance;
    gameManager.setOnWinStateChanged((winStatus) {
      if (winStatus != WinStatus.none) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await gameManager.deleteRoom();
          Navigator.pop(context);
          showDialog(
              context: context,
              useRootNavigator: false,
              builder: (context) => AlertDialog(
                    title: Text(winStatus == WinStatus.win
                        ? "You won!"
                        : (winStatus == WinStatus.loss
                            ? "You lost!"
                            : "It's a draw!")),
                  ));
        });
      }
    });
    gameManager.setOnMoveEnqueued(() {
      setState(() {
        _moveEnqueued = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (popped) async {
        if (popped) return;
        await gameManager.leaveRoom();
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select Game"),
        ),
        body: StreamBuilder(
            stream: gameManager.roomStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (!gameManager.hasMinPlayers()) {
                return const Center(
                    child: Text("Waiting for another player to join..."));
              } else if (!_moveEnqueued) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Select a choice..."),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: choices
                            .map((choice) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await gameManager
                                            .enqueueMove({"choice": choice});
                                      },
                                      child: Center(
                                          child: Text(
                                        choiceToEmoji[choice]!,
                                        style: const TextStyle(fontSize: 32),
                                      )),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                );
              }
              return const Center(
                  child: Text("Waiting for the other player to act..."));
            }),
      ),
    );
  }
}
