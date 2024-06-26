// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/game.dart';
import 'battleships_board.dart';

class PlayingGameScreen extends StatefulWidget {
  const PlayingGameScreen({super.key, required this.game,this.ai});
  final Game game;
  final String? ai;
  @override
  State<PlayingGameScreen> createState() => _PlayingGameScreenState();
}

class _PlayingGameScreenState extends State<PlayingGameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Play Game"),
      ),
      body: BattleshipsBoard(
        key: UniqueKey(),
        game: widget.game,
        onSubmit: widget.game.isComplete() ? null : _onSubmit,
      ),
    );
  }

   _onSubmit(List<dynamic> selectedsCells) async{
    if (selectedsCells.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select cell.'),
        ),
      );
      return;
    }
    int row = int.parse(selectedsCells[0][0]);
    int col = int.parse(selectedsCells[0][1]);

    if (widget.game.turn!=widget.game.position) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('opponent Turn.'),
        ),
      );
      return;
    }

    if (!widget.game.playable(row, col)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cell is not playable.'),
        ),
      );
      return;
    }
    await widget.game.playAt(row, col);

    if(!mounted) return;
    if(widget.ai!=null){
      await widget.game.refGame();
    }
    if(!mounted) return;
    setState(() {
    });


    if(!mounted) return;
    if (widget.game.isComplete()) {
      final players = [widget.game.player1, widget.game.player2];
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Winner: ${players[widget.game.status! - 1]}'),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {});
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    // if(!mounted) return;
    // Navigator.of(context).pop();

  }










}
