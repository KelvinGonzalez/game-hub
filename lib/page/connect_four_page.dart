import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:game_hub/game/connect_four.dart';
import 'package:game_hub/logic/utils.dart';
import 'package:game_hub/model/game_manager.dart';
import 'package:game_hub/model/room.dart';

class ConnectFourPage extends StatefulWidget {
  const ConnectFourPage({super.key});

  @override
  State<ConnectFourPage> createState() => _ConnectFourPageState();
}

class _ConnectFourPageState extends State<ConnectFourPage> {
  late GameManager gameManager;

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
              }
              return Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("It is ${gameManager.getCurrentPlayer()!.name}'s turn"),
                  _boardWidget(context),
                ],
              ));
            }),
      ),
    );
  }

  Widget _boardWidget(BuildContext context) {
    final board = List<int>.from(gameManager.room!.gameState["board"]);
    Widget buttons = Row(
        mainAxisSize: MainAxisSize.min,
        children: joinWidgets(
            List.generate(
                ConnectFour.width,
                (index) => SizedBox(
                      height: 50,
                      width: 50,
                      child: ElevatedButton(
                          onPressed: () async {
                            await gameManager.performMove({"position": index});
                          },
                          child: const Icon(Icons.touch_app)),
                    )),
            const SizedBox(
                height: 50.0, child: VerticalDivider(thickness: 2))));
    Widget grid = Row(
      mainAxisSize: MainAxisSize.min,
      children: joinWidgets(
          List.generate(
              ConnectFour.width,
              (j) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        ConnectFour.height,
                        (i) => SizedBox(
                            width: 50,
                            height: 50,
                            child: board[i * ConnectFour.width + j] == -1
                                ? const Center(child: Text(""))
                                : Center(
                                    child: Text("●",
                                        style: TextStyle(
                                            fontSize: 32,
                                            color: [Colors.red, Colors.blue][
                                                board[i * ConnectFour.width +
                                                    j]]))))),
                  )),
          const SizedBox(
              height: 50.0 * ConnectFour.height,
              child: VerticalDivider(thickness: 2))),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        grid,
        const SizedBox(
            width: 50.0 * (ConnectFour.width + 2),
            child: Divider(thickness: 2)),
        buttons
      ],
    );
  }
}
