import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:game_hub/game/connect_four.dart';
import 'package:game_hub/logic/utils.dart';
import 'package:game_hub/model/game_manager.dart';
import 'package:game_hub/model/room.dart';
import 'package:game_hub/model/status.dart';
import 'package:game_hub/widget/game_end_alert.dart';

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
    gameManager.setOnGameEnd((winStatus) {
      showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) => GameEndAlert(winStatus: winStatus));
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
    double size = 40;
    final board = List<int>.from(gameManager.room!.gameState["board"]);
    Widget buttons = Row(
        mainAxisSize: MainAxisSize.min,
        children: joinWidgets(
            List.generate(
                ConnectFour.width,
                (index) => SizedBox(
                      height: size,
                      width: size,
                      child: ElevatedButton(
                          onPressed: () async {
                            await gameManager.performMove({"position": index});
                          },
                          child: const Text("")),
                    )),
            SizedBox(
                height: size, child: const VerticalDivider(thickness: 2))));
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
                            width: size,
                            height: size,
                            child: board[i * ConnectFour.width + j] == -1
                                ? const Center(child: Text(""))
                                : Center(
                                    child: Text("●",
                                        style: TextStyle(
                                            fontSize: 32,
                                            color: [Colors.red, Colors.yellow][
                                                board[i * ConnectFour.width +
                                                    j]]))))),
                  )),
          SizedBox(
              height: size * ConnectFour.height,
              child: const VerticalDivider(thickness: 2))),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        grid,
        SizedBox(
            width: size * (ConnectFour.width + 2.5),
            child: const Divider(thickness: 2)),
        buttons
      ],
    );
  }
}
