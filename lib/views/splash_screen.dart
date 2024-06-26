import '../models/gamelist.dart';
import 'gamelist_screen.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final player = Provider.of<Player?>(context);

    if (player == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (player.isAnonymous()) {
      return const LoginScreen();
    }
    final games = GameList(player);
    games.loadGames(false);

    return ChangeNotifierProvider<GameList>(
      create: (_) => games,
      child: const GameListScreen(),
    );
  }
}
