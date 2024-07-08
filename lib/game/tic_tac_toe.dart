import 'package:game_hub/model/game.dart';
import 'package:pair/pair.dart';

class TicTacToe extends Game {
  @override
  String get name => "Tic Tac Toe";

  @override
  int get minPlayers => 2;

  @override
  int get maxPlayers => 2;

  @override
  Map<String, dynamic> getInitialGameState() {
    return {"board": List.filled(9, -1)};
  }

  @override
  bool performMove(Map<String, dynamic> moveData,
      Map<String, dynamic> gameState, int playerIndex) {
    if (moveData["position"] < 0 || moveData["position"] >= 9) return false;
    if (gameState["board"][moveData["position"]] != -1) return false;
    gameState["board"][moveData["position"]] = playerIndex;
    return true;
  }

  Pair<int, int> getMatrixPosition(int position) {
    if (position < 0) return const Pair(-1, -1);
    return Pair(position ~/ 3, position % 3);
  }

  bool positionOutOfBounds(int posRow, int posCol) {
    return posRow < 0 || posRow >= 3 || posCol < 0 || posCol >= 3;
  }

  int countDirection(int posRow, int posCol, int dirRow, int dirCol,
      List<int> board, int icon) {
    if (positionOutOfBounds(posRow, posCol)) return 0;
    if (icon != board[posRow * 3 + posCol]) return 0;
    return 1 +
        countDirection(
            posRow + dirRow, posCol + dirCol, dirRow, dirCol, board, icon);
  }

  @override
  int getWinner(Map<String, dynamic> gameState) {
    final board = List<int>.from(gameState["board"]);
    for (var position = 0; position < 9; position++) {
      final matrixPosition = getMatrixPosition(position);
      final directions = [
        const Pair(1, 0),
        const Pair(1, 1),
        const Pair(0, 1),
        const Pair(-1, 1)
      ];
      final icon = board[position];
      if (icon == -1) continue;
      for (var direction in directions) {
        var count = countDirection(matrixPosition.key, matrixPosition.value,
                direction.key, direction.value, board, icon) +
            countDirection(matrixPosition.key, matrixPosition.value,
                -direction.key, -direction.value, board, icon) -
            1;
        if (count >= 3) return board[position];
      }
    }
    return -1;
  }

  @override
  bool getDraw(Map<String, dynamic> gameState) {
    return !gameState["board"].any((e) => e == -1);
  }
}
