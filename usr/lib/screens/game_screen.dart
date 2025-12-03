import 'package:flutter/material.dart';
import '../logic/game_logic.dart';
import '../xp_theme.dart';
import '../widgets/xp_widgets.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MinesweeperGame _game;
  
  // Difficulty settings
  int _rows = 16;
  int _cols = 16;
  int _mines = 40;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _game = MinesweeperGame(
        rows: _rows,
        cols: _cols,
        totalMines: _mines,
        onStateChanged: () {
          if (mounted) setState(() {});
        },
      );
    });
  }

  void _changeDifficulty(int r, int c, int m) {
    setState(() {
      _rows = r;
      _cols = c;
      _mines = m;
      _startNewGame();
    });
  }

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XPColors.background,
      appBar: AppBar(
        title: const Text('Minesweeper XP'),
        backgroundColor: const Color(0xFF0055EA), // XP Title Bar Blue
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'Beginner':
                  _changeDifficulty(9, 9, 10);
                  break;
                case 'Intermediate':
                  _changeDifficulty(16, 16, 40);
                  break;
                case 'Expert':
                  _changeDifficulty(16, 30, 99);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Beginner', child: Text('Beginner (9x9)')),
              const PopupMenuItem(value: 'Intermediate', child: Text('Intermediate (16x16)')),
              const PopupMenuItem(value: 'Expert', child: Text('Expert (30x16)')),
            ],
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: BeveledContainer(
                borderWidth: 4,
                child: Container(
                  color: XPColors.background,
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      BeveledContainer(
                        borderWidth: 3,
                        isPressed: true,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SevenSegmentDisplay(value: _game.totalMines - _game.flagsPlaced),
                              SmileyButton(
                                onPressed: _game.reset,
                                isWon: _game.status == GameStatus.won,
                                isLost: _game.status == GameStatus.lost,
                              ),
                              SevenSegmentDisplay(value: _game.timeElapsed),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Game Grid
                      BeveledContainer(
                        borderWidth: 4,
                        isPressed: true,
                        child: Column(
                          children: List.generate(_rows, (r) {
                            return Row(
                              children: List.generate(_cols, (c) {
                                return _buildCell(r, c);
                              }),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int r, int c) {
    final cell = _game.grid[r][c];
    final size = 30.0;

    return GestureDetector(
      onTap: () {
        if (cell.isRevealed) {
          _game.chord(r, c);
        } else {
          _game.reveal(r, c);
        }
      },
      onLongPress: () {
        _game.toggleFlag(r, c);
      },
      child: SizedBox(
        width: size,
        height: size,
        child: _renderCellContent(cell),
      ),
    );
  }

  Widget _renderCellContent(CellModel cell) {
    if (!cell.isRevealed) {
      return BeveledContainer(
        borderWidth: 2,
        child: Center(
          child: cell.isFlagged
              ? const Icon(Icons.flag, color: Colors.red, size: 18)
              : null,
        ),
      );
    }

    // Revealed Cell
    return Container(
      decoration: BoxDecoration(
        color: cell.isExploded ? Colors.red : XPColors.background,
        border: Border.all(color: XPColors.gray, width: 0.5),
      ),
      child: Center(
        child: _getRevealedContent(cell),
      ),
    );
  }

  Widget? _getRevealedContent(CellModel cell) {
    if (cell.isMine) {
      return const Icon(Icons.settings, color: Colors.black, size: 20); // Placeholder for mine
    }
    
    if (cell.neighborMineCount > 0) {
      return Text(
        '${cell.neighborMineCount}',
        style: TextStyle(
          color: XPColors.getNumberColor(cell.neighborMineCount),
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
      );
    }
    
    return null;
  }
}
