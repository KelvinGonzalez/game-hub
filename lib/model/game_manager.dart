import 'dart:async';
import 'dart:math';

import 'package:game_hub/model/game.dart';
import 'package:game_hub/model/player.dart';
import 'package:game_hub/model/room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_hub/model/status.dart';

class GameManager {
  static const _collectionPrefix = "Room";
  static final _gameManager =
      GameManager(player: Player(id: Random().nextInt(0x80000000)));
  final Player player;
  Game? game;
  Room? room;
  DocumentReference<Map<String, dynamic>>? _reference;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _roomStream;
  StreamSubscription? _streamSubscription;
  Map<String, dynamic>? _enqueuedMoveData;

  // Event functions
  void Function(WinStatus)? _onGameEnd;
  void Function(PerformMoveStatus)? _onMovePerformed;
  void Function()? _onMoveEnqueued;

  GameManager({required this.player});

  static GameManager get instance => _gameManager;

  String get collectionName => "$_collectionPrefix:${game?.name}";

  Stream<DocumentSnapshot<Map<String, dynamic>>>? get roomStream => _roomStream;

  void setGame(Game game) {
    this.game = game;
  }

  void setPlayerName(String name) {
    player.name = name;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRooms() {
    if (game == null) throw Exception("Game has not been set");
    return FirebaseFirestore.instance.collection(collectionName).snapshots();
  }

  void setUpRoomStreamListener() {
    if (_reference == null) return;
    _roomStream = _reference!.snapshots();
    _enqueuedMoveData = null;
    _streamSubscription = _roomStream!.listen((snapshot) async {
      if (room != null && snapshot.data() != null) {
        room!.updateFromSnapshot(snapshot.data()!);

        final winStatus = getWinStatus();
        if (winStatus != WinStatus.none) {
          await onGameEnd(winStatus);
        }

        if (_enqueuedMoveData != null) {
          if (await performMove(_enqueuedMoveData!) ==
              PerformMoveStatus.success) {
            _enqueuedMoveData = null;
          }
        }
      }
    });
  }

  Future<bool> createRoom() async {
    if (game == null) return false;
    room = Room.createRoom(game!, player);
    _reference = await FirebaseFirestore.instance
        .collection(collectionName)
        .add(room!.toSnapshot());
    setUpRoomStreamListener();
    return true;
  }

  Future<RoomJoinStatus> joinRoom(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    if (game == null) throw Exception("Game not found. Ensure game is set.");
    if (snapshot.data() == null) {
      throw Exception("Snapshot data not available.");
    }
    Room room = Room.fromSnapshot(snapshot.data()!, game!);
    RoomJoinStatus joinStatus = room.joinRoom(player);
    if (joinStatus != RoomJoinStatus.success) return joinStatus;
    this.room = room;
    _reference = snapshot.reference;
    await _reference!.set(room.toSnapshot());
    setUpRoomStreamListener();
    return RoomJoinStatus.success;
  }

  Future<RoomLeaveStatus> leaveRoom() async {
    if (game == null) throw Exception("Game not found. Ensure game is set.");
    if (room == null || _reference == null) {
      throw Exception("Room reference not set.");
    }
    RoomLeaveStatus roomLeaveStatus = room!.leaveRoom(player);
    switch (roomLeaveStatus) {
      case RoomLeaveStatus.success:
      case RoomLeaveStatus.gameRestarted:
        if (room!.players.isEmpty) {
          await deleteRoom();
          return RoomLeaveStatus.deleted;
        }
        await _reference!.set(room!.toSnapshot());
        room = null;
        _reference = null;
        _streamSubscription?.cancel();
        break;
      case RoomLeaveStatus.playerNotFound:
      default:
        break;
    }
    return roomLeaveStatus;
  }

  Future<bool> deleteRoom() async {
    if (_reference == null) {
      return false;
    }
    await _reference!.delete();
    room = null;
    _reference = null;
    _streamSubscription?.cancel();
    return true;
  }

  Future<PerformMoveStatus> performMove(Map<String, dynamic> moveData) async {
    if (room == null || _reference == null) {
      throw Exception("Room reference not set.");
    }
    PerformMoveStatus performMoveStatus = room!.performMove(moveData, player);
    if (_onMovePerformed != null) _onMovePerformed!(performMoveStatus);
    if (performMoveStatus != PerformMoveStatus.success) {
      return performMoveStatus;
    }
    await _reference!.set(room!.toSnapshot());
    return PerformMoveStatus.success;
  }

  Future<void> enqueueMove(Map<String, dynamic> moveData) async {
    if (_enqueuedMoveData != null) return;
    if (_onMoveEnqueued != null) _onMoveEnqueued!();
    PerformMoveStatus performMoveStatus = await performMove(moveData);
    if (performMoveStatus == PerformMoveStatus.success) return;
    _enqueuedMoveData = moveData;
  }

  Future<void> onGameEnd(WinStatus winStatus) async {
    if (_onGameEnd != null) {
      _onGameEnd!(winStatus);
    }
    await playAgain();
  }

  Future<bool> playAgain() async {
    if (room == null || _reference == null) {
      throw Exception("Room reference not set.");
    }
    if (player != getHost()) return false;
    room!.playAgain();
    await _reference!.set(room!.toSnapshot());
    return true;
  }

  WinStatus getWinStatus() {
    if (room == null || _reference == null) {
      throw Exception("Room reference not set.");
    }
    return room!.getWinStatus(player);
  }

  Player? getHost() {
    return room?.players.firstOrNull;
  }

  bool hasMinPlayers() {
    if (room == null) return false;
    return room!.hasMinPlayers();
  }

  bool isCurrentPlayer() {
    if (room == null) return false;
    return room!.isCurrentPlayer(player);
  }

  Player? getCurrentPlayer() {
    if (room == null) return null;
    return room!.getCurrentPlayer();
  }

  void setOnGameEnd(void Function(WinStatus) callback) {
    _onGameEnd = callback;
  }

  void setOnMovePerformed(void Function(PerformMoveStatus) callback) {
    _onMovePerformed = callback;
  }

  void setOnMoveEnqueued(void Function() callback) {
    _onMoveEnqueued = callback;
  }
}
