import 'package:game_hub/model/game.dart';
import 'package:pair/pair.dart';

class ConnectFour extends Game {
  @override
  String get name => "Connect Four";

  @override
  int get minPlayers => 2;

  @override
  int get maxPlayers => 2;

  static const int width = 7;
  static const int height = 6;

  @override
  Map<String, dynamic> getInitialGameState() {
    return {"board": List.filled(width * height, -1)};
  }

  @override
  bool performMove(Map<String, dynamic> moveData,
      Map<String, dynamic> gameState, int currentPlayer) {
    int position = moveData["position"];
    if (position < 0 || position >= width) return false;
    for (int newPosition = position + width * (height - 1);
        newPosition >= 0;
        newPosition -= width) {
      if (gameState["board"][newPosition] != -1) continue;
      gameState["board"][newPosition] = currentPlayer;
      gameState["lastPosition"] = newPosition;
      return true;
    }
    return false;
  }

  Pair<int, int> getMatrixPosition(int position) {
    if (position < 0) return const Pair(-1, -1);
    return Pair(position ~/ width, position % width);
  }

  bool positionOutOfBounds(int posRow, int posCol) {
    return posRow < 0 || posRow >= height || posCol < 0 || posCol >= width;
  }

  int countDirection(int posRow, int posCol, int dirRow, int dirCol,
      List<int> board, int icon) {
    if (positionOutOfBounds(posRow, posCol)) return 0;
    if (icon != board[posRow * width + posCol]) return 0;
    return 1 +
        countDirection(
            posRow + dirRow, posCol + dirCol, dirRow, dirCol, board, icon);
  }

  @override
  int getWinner(Map<String, dynamic> gameState) {
    final board = List<int>.from(gameState["board"]);
    int? position = gameState["lastPosition"];
    if (position == null) return -1;
    final matrixPosition = getMatrixPosition(position);
    final directions = [
      const Pair(1, 0),
      const Pair(1, 1),
      const Pair(0, 1),
      const Pair(-1, 1)
    ];
    final icon = board[position];
    if (icon == -1) return -1;
    for (var direction in directions) {
      var count = countDirection(matrixPosition.key, matrixPosition.value,
              direction.key, direction.value, board, icon) +
          countDirection(matrixPosition.key, matrixPosition.value,
              -direction.key, -direction.value, board, icon) -
          1;
      if (count >= 4) return board[position];
    }
    return -1;
  }

  @override
  bool getDraw(Map<String, dynamic> gameState) {
    return !gameState["board"].any((e) => e == -1);
  }
}
