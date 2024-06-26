// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import '../models/game.dart';
import '../utils/app_config.dart';
import 'login_screen.dart';
import 'new_game.dart';
import 'playing_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gamelist.dart';
import '../utils/sessionmanager.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});
  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  bool isCompleted = false;

  Future<void> _doLogout(String msg) async {
    await SessionManager.clearSessionPlayer();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameList>(builder: (ctx, games, _) {
      if (games.isMissingToken) {
        _doLogout("The session has ended, log in again to get a new token.");
      }

      return Scaffold(
          appBar: AppBar(
            title: const Text("Battleships"),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  AppConfig.showLoading(context);
                  await games.loadGames(isCompleted);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Battleships',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Logged in as ${games.player.username}',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text("New game"),
                  onTap: () async {
                    Navigator.pop(context);
                    final ships = await Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return const NewGame();
                    }));

                    if (!mounted || ships == null) return;
                    AppConfig.showLoading(context);
                    await games.startGame(ships, null);
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.computer),
                  title: const Text("New game (AI)"),
                  onTap: () async {
                    Navigator.pop(context);
                    final ai = await _showDialog(context);

                    final ships = await Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return const NewGame();
                    }));

                    if (!mounted || ships == null) return;
                    AppConfig.showLoading(context);
                    await games.startGame(ships, ai);
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    await Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return PlayingGameScreen(
                          game: games.selectedGame!, ai: ai);
                    }));

                    if (!mounted) return;
                    await games.loadGames(false);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list),
                  title: isCompleted
                      ? const Text("Show active games")
                      : const Text("Show completed games"),
                  onTap: () async {
                    isCompleted = !isCompleted;
                    Navigator.of(context).pop();
                    AppConfig.showLoading(context);

                    await games.loadGames(isCompleted);
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Log out"),
                  onTap: () {
                    Navigator.pop(context);
                    _doLogout("Logout");
                  },
                ),
              ],
            ),
          ),
          body: ListView.builder(
            itemCount: games.items.length,
            itemBuilder: (context, index) {
              Game game = games.items[index];

              if (isCompleted) {
                return ListTile(
                  onTap: () async {
                    AppConfig.showLoading(context);
                    Game? selectedGame = await games.selectGame(index, null);
                    if (!mounted || selectedGame == null) return;
                    Navigator.of(context).pop();
                    if (!mounted) return;
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return PlayingGameScreen(game: selectedGame);
                    }));
                  },
                  leading: Text('#${game.id.toString()}'),
                  title: game.status != 0
                      ? Text(
                          '${games.player.username} vs ${games.player.username == game.player1 ? game.player2 : game.player1}')
                      : null,
                  trailing: Text(statusStr(game)),
                );
              } else {
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) async {
                    await games.removeGame(index);
                  },
                  confirmDismiss: (direction) async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("canceled / forfeited"),
                      ),
                    );
                    return true;
                  },
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete),
                  ),
                  child: ListTile(
                    onTap: () async {
                      AppConfig.showLoading(context);
                      Game? selectedGame = await games.selectGame(index, null);
                      if (!mounted || selectedGame == null) return;
                      Navigator.of(context).pop();

                      if (!mounted) return;
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (ctx) {
                        return PlayingGameScreen(game: selectedGame);
                      }));

                      if (!mounted) return;
                      AppConfig.showLoading(context);
                      await games.loadGames(false);
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    leading: Text('#${game.id.toString()}'),
                    title: game.status != 0
                        ? Text(
                            '${games.player.username} vs ${games.player.username == game.player1 ? game.player2 : game.player1}')
                        : const Text("Waiting for opponent"),
                    trailing: Text(statusStr(game)),
                  ),
                );
              }
            },
          ));
    });
  }

  String statusStr(Game game) {
    switch (game.status) {
      case 0:
        return "matchmaking";
      case 1:
        return game.position == 1 ? "won" : "lost";
      case 2:
        return game.position == 2 ? "won" : "lost";
      default:
        return game.turn == game.position ? "myTurn" : "opponentTurn";
    }
  }

  _showDialog(context) async {
    switch (await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: const Text('Who do you want to play against?'),
          content: Container(
            height: 150.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(1);
                    },
                    child: const Row(
                      children: <Widget>[
                        Text('Random'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(2);
                    },
                    child: const Row(
                      children: <Widget>[
                        Text('Perfect'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop('ai)');
                    },
                    child: const Row(
                      children: <Widget>[
                        Text('One ship (AI)'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    )) {
      case 1:
        return "random";
      case 2:
        return 'perfect';
      default:
        return "ai";
    }
  }
}
