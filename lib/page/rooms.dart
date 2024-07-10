import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:game_hub/model/game_manager.dart';
import 'package:game_hub/model/room.dart';
import 'package:game_hub/model/status.dart';
import 'package:game_hub/page/connect_four_page.dart';
import 'package:game_hub/page/rock_paper_scissors_page.dart';
import 'package:game_hub/page/tic_tac_toe_page.dart';

class Rooms extends StatefulWidget {
  const Rooms({super.key});

  @override
  State<Rooms> createState() => _RoomsState();
}

class _RoomsState extends State<Rooms> {
  Widget getGamePage() {
    final roomManager = GameManager.instance;
    switch (roomManager.game?.name) {
      case "Tic Tac Toe":
        return TicTacToePage();
      case "Rock Paper Scissors":
        return RockPaperScissorsPage();
      case "Connect Four":
        return ConnectFourPage();
      default:
        return const Placeholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomManager = GameManager.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Room"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          TextField(
            controller:
                TextEditingController(text: roomManager.player.name ?? ""),
            decoration: const InputDecoration(labelText: "Player Name"),
            onChanged: (value) {
              roomManager.setPlayerName(value);
            },
          ),
          Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: StreamBuilder(
                    stream: roomManager.getRooms(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      }
                      return Column(
                          children: snapshot.data!.docs
                              .mapIndexed(
                                  (i, doc) => _roomListItem(context, i, doc))
                              .toList());
                    },
                  ))),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: ElevatedButton(
                onPressed: () async {
                  await roomManager.createRoom();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => getGamePage()));
                },
                child: const Text("Create Room"),
              ))
            ],
          ),
        ]),
      ),
    );
  }

  Widget _roomListItem(
      BuildContext context, int i, DocumentSnapshot<Map<String, dynamic>> doc) {
    final gameManager = GameManager.instance;
    if (doc.data() == null || gameManager.game == null) return Container();
    Room room = Room.fromSnapshot(doc.data()!, gameManager.game!);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: ElevatedButton(
            onPressed: () async {
              if (await gameManager.joinRoom(doc) == RoomJoinStatus.success) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => getGamePage()));
              }
            },
            child:
                Text("Id: ${doc.id}, Host: ${room.players.firstOrNull?.name}"),
          ))
        ],
      ),
    );
  }
}
