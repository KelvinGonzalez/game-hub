import 'package:game_hub/model/player.dart';

abstract class Game {
  // Game ID name
  String get name;

  // Min number of players needed to play
  int get minPlayers;

  // Max number of allowed players
  int get maxPlayers;

  // Return game state before moves are performed.
  Map<String, dynamic> getInitialGameState();

  // Perform changes to game state that will be emitted to Firebase. Return move perform status.
  bool performMove(Map<String, dynamic> moveData,
      Map<String, dynamic> gameState, int currentPlayer);

  // Return which player index will have the next turn based on move data and current player.
  // Default is sequential (1st->2nd->...->nth->1st).
  int selectNextPlayer(Map<String, dynamic> moveData,
      Map<String, dynamic> gameState, int currentPlayer, List<Player> players) {
    return (currentPlayer + 1) % players.length;
  }

  // Return index of winning player, return -1 if no winners.
  int getWinner(Map<String, dynamic> gameState);

  // Return if the game is in a draw state. Assume "getWinner" has been already called.
  bool getDraw(Map<String, dynamic> gameState);

  // Return which player index will begin after the game is played again.
  // Default is sequential (1st->2nd->...->nth->1st).
  int selectNextStartingPlayer(Map<String, dynamic> gameState,
      int startingPlayer, List<Player> players) {
    return (startingPlayer + 1) % players.length;
  }
}
