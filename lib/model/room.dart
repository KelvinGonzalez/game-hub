import 'package:game_hub/model/game.dart';
import 'package:game_hub/model/player.dart';

enum WinStatus { win, loss, draw, none, noRoom }

enum RoomJoinStatus { success, roomFull, playerFound, noGame, noData }

enum RoomLeaveStatus {
  success,
  playerNotFound,
  gameRestarted,
  noGame,
  noRoom,
  deleted
}

enum PerformMoveStatus {
  success,
  notEnoughPlayers,
  notCurrentPlayer,
  gameRuleViolation,
  noRoom
}

class Room {
  List<Player> players;
  Map<String, dynamic> gameState;
  Game game;
  int currentPlayer;

  Room(
      {required this.game,
      required this.players,
      required this.gameState,
      required this.currentPlayer});

  static Room createRoom(Game game, Player player) {
    return Room(
        game: game,
        players: [player],
        gameState: game.getInitialGameState(),
        currentPlayer: 0);
  }

  RoomJoinStatus joinRoom(Player player) {
    if (players.length >= game.maxPlayers) return RoomJoinStatus.roomFull;
    if (players.contains(player)) return RoomJoinStatus.playerFound;
    players.add(player);
    return RoomJoinStatus.success;
  }

  void restartRoom() {
    currentPlayer = 0;
    gameState = game.getInitialGameState();
  }

  bool hasMinPlayers() {
    return players.length >= game.minPlayers;
  }

  RoomLeaveStatus leaveRoom(Player player) {
    if (!players.contains(player)) return RoomLeaveStatus.playerNotFound;
    players.remove(player);
    if (currentPlayer >= players.length) currentPlayer = 0;
    if (!hasMinPlayers()) {
      restartRoom();
      return RoomLeaveStatus.gameRestarted;
    }
    return RoomLeaveStatus.success;
  }

  bool isCurrentPlayer(Player player) {
    return currentPlayer == players.indexOf(player);
  }

  // Player validation before game.performMove
  PerformMoveStatus performMove(Map<String, dynamic> moveData, Player player) {
    if (!hasMinPlayers()) {
      return PerformMoveStatus.notEnoughPlayers;
    }
    if (!isCurrentPlayer(player)) return PerformMoveStatus.notCurrentPlayer;
    bool performedMove = game.performMove(moveData, gameState, currentPlayer);
    if (performedMove) updateCurrentPlayer(moveData);
    return performedMove
        ? PerformMoveStatus.success
        : PerformMoveStatus.gameRuleViolation;
  }

  void updateCurrentPlayer(Map<String, dynamic> moveData) {
    currentPlayer =
        game.selectNextPlayer(moveData, gameState, currentPlayer, players);
  }

  WinStatus getWinStatus(Player player) {
    if (!hasMinPlayers()) return WinStatus.none;
    int winner = game.getWinner(gameState);
    if (winner == -1) {
      return game.getDraw(gameState) ? WinStatus.draw : WinStatus.none;
    }
    return player == players[winner] ? WinStatus.win : WinStatus.loss;
  }

  static Room fromSnapshot(Map<String, dynamic> snapshot, Game game) {
    return Room(
        game: game,
        players: snapshot["players"]
            .map((e) => Player.fromJson(e))
            .toList()
            .cast<Player>(),
        gameState: snapshot["gameState"],
        currentPlayer: snapshot["gameState"]["currentPlayer"]);
  }

  void updateFromSnapshot(Map<String, dynamic> snapshot) {
    Room room = Room.fromSnapshot(snapshot, game);
    players = room.players;
    gameState = room.gameState;
    currentPlayer = room.currentPlayer;
  }

  Map<String, dynamic> toSnapshot() {
    return {
      "players": players.map((e) => e.toJson()).toList(),
      "gameState": gameState..addAll({"currentPlayer": currentPlayer}),
    };
  }

  Player getCurrentPlayer() {
    return players[currentPlayer];
  }
}
