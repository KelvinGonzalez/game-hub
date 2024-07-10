import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:game_hub/logic/utils.dart';
import 'package:game_hub/model/game_manager.dart';
import 'package:game_hub/model/room.dart';
import 'package:game_hub/model/status.dart';
import 'package:game_hub/widget/game_end_alert.dart';

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  late GameManager gameManager;

  @override
  void initState() {
    super.initState();
    gameManager = GameManager.instance;
    gameManager.setOnGameEnd((winStatus) {
      showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) => GameEndAlert(winStatus: winStatus));
    });
  }

  @override
  Widget build(BuildContext context) {
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

  Widget _tableWidget(BuildContext context) {
    Room room = gameManager.room!;
    List<IconData> icons = [Icons.close, Icons.circle_outlined];
    List<Row> rows = [];
    for (int i = 0; i < 9; i += 3) {
      rows.add(Row(
          mainAxisSize: MainAxisSize.min,
          children: joinWidgets(
              List<int>.from(room.gameState["board"])
                  .sublist(i, i + 3)
                  .mapIndexed((j, e) => Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: TextButton(
                              onPressed: () async {
                                await gameManager
                                    .performMove({"position": i + j});
                              },
                              child: e == -1
                                  ? const Text("")
                                  : Icon(icons[e], size: 48)),
                        ),
                      ))
                  .toList(),
              const SizedBox(
                  height: 100,
                  child: VerticalDivider(thickness: 2, width: 4)))));
    }
    return Column(
        children: joinWidgets(
            rows,
            const SizedBox(
                width: (100 + 4 * 2) * 3 + 4 * 2,
                child: Divider(thickness: 2, height: 4))));
  }
}
