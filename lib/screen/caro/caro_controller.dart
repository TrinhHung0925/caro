import 'package:get/get.dart';

class CaroController extends GetxController {
  // Số cột cố định = 15; số hàng tính từ kích thước khung để ô vuông
  int boardCols = 15;
  int boardRows = 15; // sẽ được set lại từ view sau khi layout

  late List<List<String>> board;
  String currentPlayer = 'X';
  int winMode = 5;
  int scoreX = 0;
  int scoreO = 0;
  bool gameOver = false;
  bool isDraw = false;
  String winnerName = '';
  List<List<int>> winningCells = [];
  List<List<int>> moveHistory = []; // [row, col] mỗi nước đi

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    winMode = args?['winMode'] ?? 5;
    _initBoard();
  }

  /// Được gọi từ view khi biết kích thước khung thực tế.
  /// Chỉ reinit nếu dimensions thay đổi.
  void applyBoardDimensions(int cols, int rows) {
    if (boardCols == cols && boardRows == rows) return;
    boardCols = cols;
    boardRows = rows;
    _resetState();
    update();
  }

  void _initBoard() {
    board = List.generate(boardRows, (_) => List.filled(boardCols, ''));
  }

  bool isWinningCell(int row, int col) {
    return winningCells.any((c) => c[0] == row && c[1] == col);
  }

  void onCellTap(int row, int col) {
    if (gameOver || board[row][col].isNotEmpty) return;

    moveHistory.add([row, col]);
    board[row][col] = currentPlayer;

    final winning = _getWinningCells(row, col, currentPlayer);
    if (winning != null) {
      winningCells = winning;
      gameOver = true;
      winnerName = currentPlayer;
      if (currentPlayer == 'X') { scoreX++; } else { scoreO++; }
      update();
      return;
    }

    if (_checkDraw()) {
      gameOver = true;
      isDraw = true;
      update();
      return;
    }

    currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    update();
  }

  List<List<int>>? _getWinningCells(int row, int col, String player) {
    const directions = [[0, 1], [1, 0], [1, 1], [-1, 1]];

    for (final dir in directions) {
      final cells = <List<int>>[[row, col]];

      for (int i = 1; i <= boardCols + boardRows; i++) {
        final r = row + dir[0] * i;
        final c = col + dir[1] * i;
        if (r < 0 || r >= boardRows || c < 0 || c >= boardCols) break;
        if (board[r][c] != player) break;
        cells.add([r, c]);
      }

      for (int i = 1; i <= boardCols + boardRows; i++) {
        final r = row - dir[0] * i;
        final c = col - dir[1] * i;
        if (r < 0 || r >= boardRows || c < 0 || c >= boardCols) break;
        if (board[r][c] != player) break;
        cells.add([r, c]);
      }

      if (cells.length >= winMode) return cells;
    }
    return null;
  }

  bool _checkDraw() {
    for (int r = 0; r < boardRows; r++) {
      for (int c = 0; c < boardCols; c++) {
        if (board[r][c].isEmpty) return false;
      }
    }
    return true;
  }

  void resetGame() {
    _resetState();
    update();
  }

  void _resetState() {
    _initBoard();
    currentPlayer = 'X';
    gameOver = false;
    isDraw = false;
    winnerName = '';
    winningCells = [];
    moveHistory = [];
  }

  void undo() {
    if (moveHistory.isEmpty) return;

    final last = moveHistory.removeLast();
    final row = last[0];
    final col = last[1];

    // Player tạo nước đi cuối = index % 2: 0→X, 1→O
    final lastPlayer = moveHistory.length % 2 == 0 ? 'X' : 'O';

    if (gameOver) {
      if (!isDraw && winnerName.isNotEmpty) {
        if (winnerName == 'X') {
          scoreX = (scoreX - 1).clamp(0, 999);
        } else {
          scoreO = (scoreO - 1).clamp(0, 999);
        }
      }
      gameOver = false;
      isDraw = false;
      winnerName = '';
      winningCells = [];
    }

    board[row][col] = '';
    currentPlayer = lastPlayer;
    update();
  }

}
