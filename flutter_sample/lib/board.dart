import 'dart:math' show Random;

class Board {
  final int row;
  final int column;
  late int score;
  late List<List<Tile>> _boardTiles;

  /// Initializes the board with the given number of rows and columns.
  Board(this.row, this.column) {
    initBoard(); // Initialize the board and score here
  } // Initialize to an empty list

  void initBoard() {
    _boardTiles = List.generate(
      row,
      (r) => List.generate(
            column,
            (c) => Tile(
                  row: r,
                  column: c,
                  value: 0,
                  isNew: false,
                  canMerge: false,
                ),
          ),
    );

    print(_boardTiles);

    score = 0;
    resetCanMerge();
    randomEmptyTile();
    randomEmptyTile();
  }

  void moveLeft() {
    if (!canMoveLeft()) return;
    for (int r = 0; r < row; ++r) {
      for (int c = 0; c < column; ++c) {
        mergeLeft(r, c);
      }
    }
    randomEmptyTile();
    resetCanMerge();
  }

  void moveRight() {
    if (!canMoveRight()) return;
    for (int r = 0; r < row; ++r) {
      for (int c = column - 2; c >= 0; --c) {
        mergeRight(r, c);
      }
    }
    randomEmptyTile();
    resetCanMerge();
  }

  void moveUp() {
    if (!canMoveUp()) return;
    for (int r = 0; r < row; ++r) {
      for (int c = 0; c < column; ++c) {
        mergeUp(r, c);
      }
    }
    randomEmptyTile();
    resetCanMerge();
  }

  void moveDown() {
    if (!canMoveDown()) return;
    for (int r = row - 2; r >= 0; --r) {
      for (int c = 0; c < column; ++c) {
        mergeDown(r, c);
      }
    }
    randomEmptyTile();
    resetCanMerge();
  }

  bool canMoveLeft() {
    for (int r = 0; r < row; ++r) {
      for (int c = 1; c < column; ++c) {
        if (canMerge(_boardTiles[r][c], _boardTiles[r][c - 1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMoveRight() {
    for (int r = 0; r < row; ++r) {
      for (int c = column - 2; c >= 0; --c) {
        if (canMerge(_boardTiles[r][c], _boardTiles[r][c + 1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMoveUp() {
    for (int r = 1; r < row; ++r) {
      for (int c = 0; c < column; ++c) {
        if (canMerge(_boardTiles[r][c], _boardTiles[r - 1][c])) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMoveDown() {
    for (int r = row - 2; r >= 0; --r) {
      for (int c = 0; c < column; ++c) {
        if (canMerge(_boardTiles[r][c], _boardTiles[r + 1][c])) {
          return true;
        }
      }
    }
    return false;
  }

  void mergeLeft(int row, int col) {
    while (col > 0) {
      merge(_boardTiles[row][col], _boardTiles[row][col - 1]);
      col--;
    }
  }

  void mergeRight(int row, int col) {
    while (col < column - 1) {
      merge(_boardTiles[row][col], _boardTiles[row][col + 1]);
      col++;
    }
  }

  void mergeUp(int r, int col) {
    while (r > 0) {
      merge(_boardTiles[r][col], _boardTiles[r - 1][col]);
      r--;
    }
  }

  void mergeDown(int r, int col) {
    while (r < row - 1) {
      merge(_boardTiles[r][col], _boardTiles[r + 1][col]);
      r++;
    }
  }

  bool canMerge(Tile a, Tile b) {
    return !a.canMerge &&
        ((b.isEmpty() && !a.isEmpty()) || (!a.isEmpty() && a == b));
  }

  void merge(Tile a, Tile b) {
    if (!canMerge(a, b)) {
      if (!a.isEmpty() && !b.canMerge) {
        b.canMerge = true;
      }
      return;
    }

    if (b.isEmpty()) {
      b.value = a.value;
      a.value = 0;
    } else if (a == b) {
      b.value = b.value * 2;
      a.value = 0;
      score += b.value;
      b.canMerge = true;
    } else {
      b.canMerge = true;
    }
  }

  bool gameOver() {
    return !canMoveLeft() && !canMoveRight() && !canMoveUp() && !canMoveDown();
  }

  Tile getTile(int row, int column) {
    return _boardTiles[row][column];
  }

  void randomEmptyTile() {
    List<Tile> empty = [];
    for (var row in _boardTiles) {
      empty.addAll(row.where((tile) => tile.isEmpty()));
    }

    if (empty.isNotEmpty) {
      Random rng = Random();
      int index = rng.nextInt(empty.length);
      empty[index].value = rng.nextInt(9) == 0 ? 4 : 2;
      empty[index].isNew = true;
    }
  }

  void resetCanMerge() {
    for (var row in _boardTiles) {
      for (var tile in row) {
        tile.canMerge = false;
      }
    }
  }
}

class Tile {
  final int row, column;
  int value;
  bool canMerge;
  bool isNew;

  Tile({
    required this.row,
    required this.column,
    this.value = 0,
    required this.canMerge,
    required this.isNew,
  });

  bool isEmpty() => value == 0;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Tile && value == other.value);
}
