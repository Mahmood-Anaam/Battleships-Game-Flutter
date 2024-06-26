import '../models/game.dart';
import 'package:flutter/material.dart';

class BattleshipsBoard extends StatefulWidget {
  final Game game;
  final Function(List<dynamic> selectedsCells)? onSubmit;
  const BattleshipsBoard({super.key, required this.game, this.onSubmit});

  @override
  State<BattleshipsBoard> createState() => _BattleshipsBoardState();
}

class _BattleshipsBoardState extends State<BattleshipsBoard> {
  List<String> selectedsCells = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final aspectRatio = constraints.maxWidth / constraints.maxHeight;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6, childAspectRatio: aspectRatio),
                itemCount: 36,
                padding: const EdgeInsets.all(1),
                itemBuilder: (context, index) {
                  int row = index ~/ 6;
                  int col = index % 6;

                  String? content;

                  if (row == 0 && col == 0) {
                    content = "";
                  } else if (row == 0) {
                    content = '$col';
                  } else if (col == 0) {
                    content = String.fromCharCode('A'.codeUnitAt(0) + row - 1);
                  }

                  return Card(
                      color: selectedsCells.contains('${row - 1}${col - 1}')
                          ? Colors.blue
                          : null,
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      child: content == null
                          ? InkWell(
                              key: ValueKey('cell-$row-$col'),
                              onTap: () => _onTapCard(row - 1, col - 1),
                              splashColor: Colors.blue,
                              hoverColor:
                                  const Color.fromRGBO(242, 228, 178, 0.3),
                              child: Center(
                                child:
                                  switch (widget.game[(row - 1, col - 1)]) {
                                    StatePosBoard.ship => const Icon(Icons.directions_boat_outlined,color: Colors.blue,),
                                    StatePosBoard.wreck =>const Icon(Icons.bubble_chart_outlined,color: Colors.blue,),
                                    StatePosBoard.shot => const Icon(Icons.local_fire_department_rounded,color: Colors.black,),
                                    StatePosBoard.sunk =>const Icon(Icons.bolt,color: Colors.red,),
                                    _ => null,
                                  },
                                ),

                            )
                          : Center(
                              child: Text(
                                content,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ));
                },
              );
            }),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: widget.onSubmit != null
                ? () => widget.onSubmit!(selectedsCells)
                : null,
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30)),
            child: const Text("Submit"),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  _onTapCard(int row, int col) {
    if (!widget.game.isAnonymous() && widget.game.isComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game is over. Please create new game to play again.'),
        ),
      );
      return;
    }
    if (selectedsCells.contains('$row$col')) {
      setState(() {
        selectedsCells.remove('$row$col');
      });
      return;
    } else if (widget.game.isAnonymous() && selectedsCells.length == 5) {
      return;
    } else if (!widget.game.isAnonymous() && selectedsCells.length == 1) {
      setState(() {
        selectedsCells.removeLast();
        if (widget.game.playable(row, col)) {
          selectedsCells.add('$row$col');
        }
      });

      return;
    } else {
      setState(() {
        if (widget.game.playable(row, col)) {
          selectedsCells.add('$row$col');
        }
      });
      return;
    }
  }
}
