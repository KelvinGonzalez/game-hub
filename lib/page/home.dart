import 'package:flutter/material.dart';
import 'package:game_hub/game/rock_paper_scissors.dart';
import 'package:game_hub/game/tic_tac_toe.dart';
import 'package:game_hub/model/game.dart';
import 'package:game_hub/model/game_manager.dart';
import 'package:game_hub/page/rooms.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Game> games = [TicTacToe(), RockPaperScissors()];

  @override
  Widget build(BuildContext context) {
    final gameManager = GameManager.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Game"),
      ),
      body: Column(
        children: games
            .map((game) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        gameManager.setGame(game);
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Rooms()));
                      },
                      child: SizedBox(
                          width: double.infinity,
                          child: Center(child: Text(game.name)))),
                ))
            .toList(),
      ),
    );
  }
}
