import 'dart:async';
import 'dart:math';

enum GameStatus { playing, won, lost, waiting }

class CellModel {
  final int row;
  final int col;
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  bool isExploded; // The specific mine that caused the loss
  int neighborMineCount;

  CellModel({
    required this.row,
    required this.col,
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.isExploded = false,
    this.neighborMineCount = 0,
  });
}

class MinesweeperGame {
  final int rows;
  final int cols;
  final int totalMines;
  
  late List<List<CellModel>> grid;
  GameStatus status = GameStatus.waiting;
  int flagsPlaced = 0;
  int startTime = 0;
  int timeElapsed = 0;
  Timer? _timer;
  final void Function() onStateChanged;

  MinesweeperGame({
    required this.rows,
    required this.cols,
    required this.totalMines,
    required this.onStateChanged,
  }) {
    reset();
  }

  void reset() {
    status = GameStatus.waiting;
    flagsPlaced = 0;
    timeElapsed = 0;
    _timer?.cancel();
    
    grid = List.generate(rows, (r) => List.generate(cols, (c) => CellModel(row: r, col: c)));
    onStateChanged();
  }

  void _startGame(int firstRow, int firstCol) {
    status = GameStatus.playing;
    _placeMines(firstRow, firstCol);
    _calculateNeighbors();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    startTime = DateTime.now().millisecondsSinceEpoch;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeElapsed++;
      if (timeElapsed > 999) timeElapsed = 999;
      onStateChanged();
    });
  }

  void _placeMines(int safeRow, int safeCol) {
    int minesPlaced = 0;
    final random = Random();

    while (minesPlaced < totalMines) {
      int r = random.nextInt(rows);
      int c = random.nextInt(cols);

      // Don't place mine on the first clicked cell or its neighbors (safe start)
      if (!grid[r][c].isMine && (r < safeRow - 1 || r > safeRow + 1 || c < safeCol - 1 || c > safeCol + 1)) {
        grid[r][c].isMine = true;
        minesPlaced++;
      }
    }
  }

  void _calculateNeighbors() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c].isMine) continue;
        
        int count = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            int nr = r + dr;
            int nc = c + dc;
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && grid[nr][nc].isMine) {
              count++;
            }
          }
        }
        grid[r][c].neighborMineCount = count;
      }
    }
  }

  void reveal(int r, int c) {
    if (status == GameStatus.lost || status == GameStatus.won) return;
    if (grid[r][c].isFlagged || grid[r][c].isRevealed) return;

    if (status == GameStatus.waiting) {
      _startGame(r, c);
    }

    if (grid[r][c].isMine) {
      _gameOver(r, c);
    } else {
      _revealRecursive(r, c);
      _checkWin();
    }
    onStateChanged();
  }

  void _revealRecursive(int r, int c) {
    if (r < 0 || r >= rows || c < 0 || c >= cols || grid[r][c].isRevealed || grid[r][c].isFlagged) return;

    grid[r][c].isRevealed = true;

    if (grid[r][c].neighborMineCount == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr != 0 || dc != 0) {
            _revealRecursive(r + dr, c + dc);
          }
        }
      }
    }
  }

  void toggleFlag(int r, int c) {
    if (status != GameStatus.playing && status != GameStatus.waiting) return;
    if (grid[r][c].isRevealed) return;

    if (grid[r][c].isFlagged) {
      grid[r][c].isFlagged = false;
      flagsPlaced--;
    } else {
      grid[r][c].isFlagged = true;
      flagsPlaced++;
    }
    onStateChanged();
  }

  void chord(int r, int c) {
    if (status != GameStatus.playing) return;
    if (!grid[r][c].isRevealed || grid[r][c].neighborMineCount == 0) return;

    int flaggedNeighbors = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        int nr = r + dr;
        int nc = c + dc;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && grid[nr][nc].isFlagged) {
          flaggedNeighbors++;
        }
      }
    }

    if (flaggedNeighbors == grid[r][c].neighborMineCount) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          int nr = r + dr;
          int nc = c + dc;
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
            if (!grid[nr][nc].isFlagged && !grid[nr][nc].isRevealed) {
              reveal(nr, nc);
            }
          }
        }
      }
    }
  }

  void _gameOver(int r, int c) {
    status = GameStatus.lost;
    grid[r][c].isExploded = true;
    _timer?.cancel();
    
    // Reveal all mines
    for (var row in grid) {
      for (var cell in row) {
        if (cell.isMine && !cell.isFlagged) {
          cell.isRevealed = true;
        }
      }
    }
  }

  void _checkWin() {
    bool allSafeRevealed = true;
    for (var row in grid) {
      for (var cell in row) {
        if (!cell.isMine && !cell.isRevealed) {
          allSafeRevealed = false;
          break;
        }
      }
    }

    if (allSafeRevealed) {
      status = GameStatus.won;
      flagsPlaced = totalMines; // Force flag count to match mines
      _timer?.cancel();
    }
  }
  
  void dispose() {
    _timer?.cancel();
  }
}
