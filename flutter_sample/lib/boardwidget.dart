
import 'package:flutter/material.dart';
import 'package:flutter_sample/board.dart';
import 'package:flutter_sample/profilescreen.dart';
import 'package:flutter_sample/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardWidget extends StatefulWidget {
  const BoardWidget({super.key});

  @override
  _BoardWidgetState createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  late Board _board;
  late int row;
  late int column;
  int highScore = 0; // High score variable
  bool _isMoving = false;
  bool gameOver = false;
  double tilePadding = 4.0; // Adjusted padding for tiles
  late MediaQueryData _queryData;

  @override
  void initState() {
    super.initState();
    row = 4;
    column = 4;
    _board = Board(row, column);

    // Load high score from local storage
    loadHighScoreLocally();

    // Start a new game
    newGame();
  }

  Future<void> saveHighScoreLocally(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', score);
  }

  Future<void> loadHighScoreLocally() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0; // Default to 0 if not found
    });
  }

  Future<void> updateHighScoreLocally(int score) async {
    if (score > highScore) {
      setState(() {
        highScore = score;
      });
      await saveHighScoreLocally(score);
      print('High score updated locally: $highScore');
    }
  }

  void newGame() {
    if (_board.score > highScore) {
      updateHighScoreLocally(_board.score);
    }

    setState(() {
      _board.initBoard();
      gameOver = false;
    });
    print('New game started successfully.');
  }

  void gameover() {
    if (_board.gameOver()) {
      setState(() {
        gameOver = true;
      });

      if (_board.score > highScore) {
        updateHighScoreLocally(_board.score);
      }
    }
  }

  Size boardSize() {
    double size = _queryData.size.width * 0.99; // Adjust to fit tiles better
    return Size(size, size);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    _queryData = MediaQuery.of(context);

    List<TileWidget> tileWidgets = [];
    for (int r = 0; r < row; ++r) {
      for (int c = 0; c < column; ++c) {
        tileWidgets.add(TileWidget(tile: _board.getTile(r, c), state: this));
      }
    }

    return Container(
      color: const Color.fromRGBO(250, 240, 230, 20),
      child: Column(
        children: <Widget>[
          Stack(
            children: [
              Positioned(
                top: 20,
                right: 20,
                child: _buildHighScoreBox(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildScoreBox("Score", _board.score),
                    const SizedBox(width: 180),
                    SizedBox(
                      width: screenWidth * 0.2,
                      height: 60,
                      child: IconButton(
                        onPressed: newGame,
                        icon: const Icon(Icons.refresh),
                        color: const Color.fromRGBO(205, 133, 63, 50),
                        iconSize: 50,
                        tooltip: "reset",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (gameOver)
            const Text(
              'Game Over',
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
          SizedBox(
            width: _queryData.size.width,
            height: _queryData.size.width,
            child: GestureDetector(
              onVerticalDragUpdate: (detail) {
                if (detail.delta.distance == 0 || _isMoving) return;
                _isMoving = true;
                setState(() {
                  if (detail.delta.direction > 0) {
                    _board.moveDown();
                  } else {
                    _board.moveUp();
                  }
                  gameover();
                });
              },
              onVerticalDragEnd: (_) => _isMoving = false,
              onHorizontalDragUpdate: (detail) {
                if (detail.delta.distance == 0 || _isMoving) return;
                _isMoving = true;
                setState(() {
                  if (detail.delta.direction > 0) {
                    _board.moveLeft();
                  } else {
                    _board.moveRight();
                  }
                  gameover();
                });
              },
              onHorizontalDragEnd: (_) => _isMoving = false,
              child: Stack(
                children: <Widget>[MyHomePage(state: this), ...tileWidgets],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBox(String title, int score) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.3,
      height: 70,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange[100],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 25, decoration: TextDecoration.none),
          ),
          Text(
            "$score",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighScoreBox() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const ProfileScreen()));
            },
            icon: const Icon(Icons.person),
            color: const Color.fromRGBO(243, 163, 63, 50),
            iconSize: 50,
          ),
        ),
        const SizedBox(width: 200),
        Container(
          width: 120,
          height: 70,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.orange[200],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "High Score",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.redAccent,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                "$highScore",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}




class TileWidget extends StatefulWidget {
  final Tile tile;
  final _BoardWidgetState state;

  const TileWidget({required this.tile, required this.state, super.key});

  @override
  _TileWidgetState createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    widget.tile.isNew = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tile.isNew && !widget.tile.isEmpty()) {
      controller.reset();
      controller.forward();
      widget.tile.isNew = false;
    } else {
      controller.animateTo(1.0);
    }

    return AnimatedTileWidget(
      tile: widget.tile,
      state: widget.state,
      animation: animation,
    );
  }
}

class AnimatedTileWidget extends AnimatedWidget {
  final Tile tile;
  final _BoardWidgetState state;

  const AnimatedTileWidget({
    required this.tile,
    required this.state,
    required Animation<double> animation,
    super.key,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    double animationValue = animation.value;
    Size boardSize = state.boardSize();
    double width = (boardSize.width - (state.column + 1) * state.tilePadding) / state.column;

    if (tile.value == 0) {
      return Container();
    } else {
      Color tileColor = tileColors[tile.value] ?? Colors.orange[50]!;

      return TileBox(
        left: (tile.column * width + state.tilePadding * (tile.column + 1)) +
            width / 2 * (1 - animationValue),
        top: tile.row * width +
            state.tilePadding * (tile.row + 1) +
            width / 2 * (1 - animationValue),
        size: width * animationValue,
        color: tileColor,
        text: Text('${tile.value}'),
      );
    }
  }
}

class TileBox extends StatelessWidget {
  final double left;
  final double top;
  final double size;
  final Color color;
  final Text text;

  const TileBox({
    required this.left,
    required this.top,
    required this.size,
    required this.color,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color,
        borderRadius: BorderRadius.circular(6)),
        
        child: Center(
          child: Text(text.data ?? '',
          style: TextStyle(
            fontSize: size * 0.3,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),),
      ),
      ),
    );
  }
}
class MyHomePage extends StatelessWidget {
  final _BoardWidgetState state;

  const MyHomePage({super.key, required this.state});
  
  @override
  Widget build(BuildContext context) {
    
    
    Size boardSize = state.boardSize();
    double width = (boardSize.width - (state.column + 1) * state.tilePadding) / state.column;

    List<TileBox> backgroundBox = [];
    for (int r = 0; r < state.row; ++r) {
      for (int c = 0; c < state.column; ++c) {
        TileBox tile = TileBox(
          left: c * width + state.tilePadding * (c + 1),
          top: r * width + state.tilePadding * (r + 1),
          size: width,
          color: tileColors[0] ?? const Color.fromRGBO(160,82,45, 100),  // Use the appropriate color based on tile value
          text: const Text(''),  // Add tile value as text if needed
        );

        backgroundBox.add(tile);
      }
    }

    return Positioned(
    
      left: 0.0,
      top: 0.0,
      child: Container(
        width: state.boardSize().width,
        height: state.boardSize().width,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(140, 120, 60, 80),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: backgroundBox,
        ),
      ),
    );
  }
}


