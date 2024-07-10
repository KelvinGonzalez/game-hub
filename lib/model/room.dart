import 'package:game_hub/model/game.dart';
import 'package:game_hub/model/player.dart';
import 'package:game_hub/model/status.dart';

class Room {
  List<Player> players;
  Map<String, dynamic> gameState;
  Game game;
  int currentPlayer;
  int startingPlayer;

  Room(
      {required this.game,
      required this.players,
      required this.gameState,
      required this.currentPlayer,
      required this.startingPlayer});

  static Room createRoom(Game game, Player player) {
    return Room(
        game: game,
        players: [player],
        gameState: game.getInitialGameState(),
        currentPlayer: 0,
        startingPlayer: 0);
  }

  RoomJoinStatus joinRoom(Player player) {
    if (players.length >= game.maxPlayers) return RoomJoinStatus.roomFull;
    if (players.contains(player)) return RoomJoinStatus.playerFound;
    players.add(player);
    return RoomJoinStatus.success;
  }

  void resetGameState() {
    currentPlayer = 0;
    startingPlayer = 0;
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
      resetGameState();
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

  void playAgain() {
    int startingPlayer =
        game.selectNextStartingPlayer(gameState, this.startingPlayer, players);
    resetGameState();
    this.startingPlayer = startingPlayer;
    currentPlayer = startingPlayer;
  }

  static Room fromSnapshot(Map<String, dynamic> snapshot, Game game) {
    return Room(
        game: game,
        players: snapshot["players"]
            .map((e) => Player.fromJson(e))
            .toList()
            .cast<Player>(),
        gameState: snapshot["gameState"],
        currentPlayer: snapshot["gameState"]["currentPlayer"],
        startingPlayer: snapshot["gameState"]["startingPlayer"]);
  }

  void updateFromSnapshot(Map<String, dynamic> snapshot) {
    Room room = Room.fromSnapshot(snapshot, game);
    players = room.players;
    gameState = room.gameState;
    currentPlayer = room.currentPlayer;
    startingPlayer = room.startingPlayer;
  }

  Map<String, dynamic> toSnapshot() {
    return {
      "players": players.map((e) => e.toJson()).toList(),
      "gameState": gameState
        ..addAll(
            {"currentPlayer": currentPlayer, "startingPlayer": startingPlayer}),
    };
  }

  Player getCurrentPlayer() {
    return players[currentPlayer];
  }
}
