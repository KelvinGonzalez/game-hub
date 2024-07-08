import 'package:game_hub/model/game.dart';

class RockPaperScissors extends Game {
  @override
  String get name => "Rock Paper Scissors";

  @override
  int get minPlayers => 2;

  @override
  int get maxPlayers => 2;

  Map<String, String> strengths = {
    "Rock": "Scissors",
    "Scissors": "Paper",
    "Paper": "Rock"
  };

  @override
  Map<String, dynamic> getInitialGameState() {
    return {
      "responses": [null, null]
    };
  }

  @override
  bool performMove(Map<String, dynamic> moveData,
      Map<String, dynamic> gameState, int playerIndex) {
    if (!strengths.containsKey(moveData["choice"])) return false;
    gameState["responses"][playerIndex] = moveData["choice"];
    return true;
  }

  @override
  int getWinner(Map<String, dynamic> gameState) {
    final responses = List<String?>.from(gameState["responses"]);
    if (responses.any((e) => e == null)) return -1;
    if (responses[0] == responses[1]) return -1;
    return strengths[responses[0]] == responses[1] ? 0 : 1;
  }

  @override
  bool getDraw(Map<String, dynamic> gameState) {
    final responses = List<String?>.from(gameState["responses"]);
    return !responses.any((e) => e == null);
  }
}
