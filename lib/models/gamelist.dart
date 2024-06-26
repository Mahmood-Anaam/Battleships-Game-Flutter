import 'dart:convert';

import '../models/game.dart';
import '../models/player.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/game_services.dart';

class GameList extends ChangeNotifier {
  late GameServices gameServices;
  final Player player;
  List<Game> _games = [];
  List<Game> get items => _games;
  Game? selectedGame;

  bool isMissingToken = false;

  GameList(this.player) {
    gameServices = GameServices(authorization: 'Bearer ${player.token}');
  }

  bool checkMissingToken(int statusCode) {
    isMissingToken = statusCode == 401;
    return isMissingToken;
  }

  void addGame(Game game) {
    _games.add(game);
    notifyListeners();
  }

  Future<void> loadGames(bool isCompleted) async {
    http.Response response = await gameServices.getGames();
    if (checkMissingToken(response.statusCode)) {
      notifyListeners();
    } else {
      final lstJson = json.decode(response.body)["games"] as List;
      final games = lstJson.map((e) {
        Map<String, dynamic> map = e as Map<String, dynamic>;
        map["authorization"] = 'Bearer ${player.token}';
        return Game.fromJson(map);
      }).toList();

      _games = games.where((e) => e.isComplete() == isCompleted).toList();
      notifyListeners();
    }
  }

  Future<void> startGame(List<String> ships, String? ai) async {
    http.Response response = await gameServices.newGame(ships, ai);
    if (checkMissingToken(response.statusCode)) {
      notifyListeners();
    } else {
      await selectGame(null, json.decode(response.body)['id']);
      await loadGames(false);
    }
  }

  Future<Game?> selectGame(int? index, int? id) async {
    final gameId = index != null ? _games[index].id! : id;
    http.Response response = await gameServices.getGame(gameId!);
    if (checkMissingToken(response.statusCode)) {
      notifyListeners();
      return null;
    } else {
      var gameJson = json.decode(response.body);
      gameJson["authorization"] = 'Bearer ${player.token}';
      selectedGame = Game.fromJson(gameJson);
      return selectedGame;
    }
  }

  Future<void> removeGame(int index) async {
    if (index >= _games.length) return;
    http.Response response = await gameServices.cancelGame(_games[index].id!);
    if (checkMissingToken(response.statusCode)) {
      notifyListeners();
    } else {
      _games.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> playGame(String shot) async {
    if (selectedGame == null) return;
    http.Response response =
        await gameServices.playGame(selectedGame!.id!, shot);
    if (checkMissingToken(response.statusCode)) {
      notifyListeners();
    } else if (response.statusCode == 200) {
      notifyListeners();
    }
  }
}
