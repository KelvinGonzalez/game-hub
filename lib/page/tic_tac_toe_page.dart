import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:game_hub/model/game_manager.dart';
import 'package:game_hub/model/room.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  Widget build(BuildContext context) {
    final gameManager = GameManager.instance;
    if (gameManager.room == null) return const Placeholder();
    return PopScope(
      canPop: false,
      onPopInvoked: (popped) async {
        if (popped) return;
        await gameManager.leaveRoom();
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("In-game"),
        ),
        body: StreamBuilder(
            stream: gameManager.roomStream!,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }

              WinStatus winStatus = gameManager.getWinStatus();
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
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!gameManager.hasMinPlayers())
                      const Text("Waiting for more players..."),
                    if (gameManager.hasMinPlayers())
                      Column(
                        children: [
                          Text(
                              "It is ${gameManager.getCurrentPlayer()!.name}'s turn"),
                          _tableWidget(context),
                        ],
                      ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}

Widget _tableWidget(BuildContext context) {
  GameManager gameManager = GameManager.instance;
  Room room = gameManager.room!;
  List<IconData> icons = [Icons.close, Icons.circle_outlined];
  List<Row> rows = [];
  for (int i = 0; i < 9; i += 3) {
    rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: List<int>.from(room.gameState["board"])
            .sublist(i, i + 3)
            .mapIndexed((j, e) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: ElevatedButton(
                        onPressed: () async {
                          await gameManager.performMove({"position": i + j});
                        },
                        child: e == -1
                            ? const Text("")
                            : Icon(icons[e], size: 48)),
                  ),
                ))
            .toList()));
  }
  return Column(children: rows);
}
