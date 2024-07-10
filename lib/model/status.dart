enum WinStatus { win, loss, draw, none }

enum RoomJoinStatus { success, roomFull, playerFound }

enum RoomLeaveStatus { success, playerNotFound, gameRestarted, deleted }

enum PerformMoveStatus {
  success,
  notEnoughPlayers,
  notCurrentPlayer,
  gameRuleViolation
}
