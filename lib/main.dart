import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/player.dart';
import 'utils/sessionmanager.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(MaterialApp(
      theme: ThemeData.light().copyWith(
          primaryColor: Colors.blue,
          appBarTheme: ThemeData.light().appBarTheme.copyWith(
              backgroundColor: Colors.blue,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
              foregroundColor: Colors.white)),
      debugShowCheckedModeBanner: false,
      title: 'Battleships',
      home: const MyGame()));
}

class MyGame extends StatelessWidget {
  const MyGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureProvider<Player?>(
        create: (_) => SessionManager.getSessionPlayer(),
        initialData: null,
        child: const SplashScreen(),
      ),
    );
  }
}
