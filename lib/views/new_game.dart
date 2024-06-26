import 'package:flutter/material.dart';

import '../models/game.dart';
import 'battleships_board.dart';

class NewGame extends StatefulWidget {
  const NewGame({super.key});
  @override
  State<NewGame> createState() => _NewGameState();
}

class _NewGameState extends State<NewGame> {
  Game game = Game.anonymous();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:  const Text("Place ships"),
      ),

      body: BattleshipsBoard(
        key: UniqueKey(),
        game: game,
        onSubmit: _onSubmit,
      ),


    );

  }


  void _onSubmit(List<dynamic>selectedsCells) {

    if(selectedsCells.isEmpty || selectedsCells.length<5){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select 5 cell.'),
        ),
      );
      return;
    }
    List<String> ships = [];
    for(var pos in selectedsCells){
      int row = int.parse(pos[0]);
      int col = int.parse(pos[1]);
      ships.add(game.convertIndexesToShot(row, col));
    }
    Navigator.of(context).pop(ships);

  }



}
