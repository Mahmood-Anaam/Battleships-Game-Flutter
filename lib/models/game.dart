// ignore_for_file: prefer_final_fields

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';

enum StatePosBoard {
  none,
  ship,
  wreck,
  sunk,
  shot,
  shipShot,
  wreckShot,
  shipSunk
}

class Game extends ChangeNotifier {
  List<List<StatePosBoard>> _board =
      List.generate(5, (_) => List.filled(5, StatePosBoard.none));

  final int? id;
  final String authorization;
  String? player1;
  String? player2;
  int? position;
  int? status;
  int? turn;
String? ai;
  List<dynamic> ships;
  List<dynamic> shots;
  List<dynamic> sunk;
  List<dynamic> wrecks;

  bool isMissingToken = false;

  Game({
    required this.id,
    required this.authorization,
    this.position,
    this.status,
    this.turn,
    this.ai,
    this.ships = const [],
    this.shots = const [],
    this.sunk = const [],
    this.wrecks = const [],
    this.player1,
    this.player2,
  }) {
    updateBoard(ships, StatePosBoard.ship);
    updateBoard(shots, StatePosBoard.shot);
    updateBoard(sunk, StatePosBoard.sunk);
    updateBoard(wrecks, StatePosBoard.wreck);
  }

  void updateBoard(List<dynamic> positions, StatePosBoard state) {
    for (var element in positions) {
      final indexes = convertShotToIndexes(element.toString());
      _board[indexes[0]][indexes[1]] = state;
    }
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
        id: json["id"],
        authorization: json["authorization"],
        player1: json['player1'],
        player2: json['player2'],
        position: json['position'],
        turn: json['turn'],
        ai:json['ai'],
        status: json['status'],
        ships: json['ships'] ?? [],
        shots: json['shots'] ?? [],
        sunk: json['sunk'] ?? [],
        wrecks: json['wrecks'] ?? []);
  }

  copy(Map<String, dynamic> json) {
    player1 = json['player1'];
    player2 = json['player2'];
    position = json['position'];
    turn = json['turn'];
    ai = json['ai'];
    status = json['status'];
    ships = json['ships'] ?? [];
    shots = json['shots'] ?? [];
    sunk = json['sunk'] ?? [];
    wrecks = json['wrecks'] ?? [];
    updateBoard(ships, StatePosBoard.ship);
    updateBoard(shots, StatePosBoard.shot);
    updateBoard(sunk, StatePosBoard.sunk);
    updateBoard(wrecks, StatePosBoard.wreck);
  }

  factory Game.anonymous() {
    return Game(id: null, authorization: '');
  }

  bool isAnonymous() {
    return id == null;
  }

  StatePosBoard operator []((int, int) position) {
    var (row, col) = position;
    return _board[row][col];
  }

  bool isComplete() {
    return status == 1 || status == 2;
  }

  bool playable(int row, int col) {
    return _board[row][col] == StatePosBoard.none;
  }

  bool checkMissingToken(int statusCode) {
    isMissingToken = statusCode == 401;
    return isMissingToken;
  }

  List<int> convertShotToIndexes(String pos) {
    int row = (pos[0].codeUnitAt(0) - "A".codeUnitAt(0));
    int col = int.parse(pos[1]) - 1;
    return [row, col];
  }

  String convertIndexesToShot(int row, int col) {
    String pos = '${(String.fromCharCode("A".codeUnitAt(0) + row))}${col + 1}';
    return pos;
  }

  Future<void> playAt(int row, int col) async {
    String shot = convertIndexesToShot(row, col);
    final response = await http.put(
        Uri.parse('${AppConfig.gamesUrl.toString()}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authorization
        },
        body: jsonEncode({'shot': shot}));
    if (checkMissingToken(response.statusCode)) {
      notifyListeners();
    } else if (response.statusCode == 200) {
      final indexes = convertShotToIndexes(shot);
      final map = json.decode(response.body);
      if (map['won']) {
        status = position;
      }
      if (map['sunk_ship']) {
        _board[indexes[0]][indexes[1]] = StatePosBoard.sunk;
      } else {
        _board[indexes[0]][indexes[1]] = StatePosBoard.shot;
      }

      notifyListeners();
    }


  }

  Future<void> refGame() async {
    final response = await http.get(
      Uri.parse('${AppConfig.gamesUrl.toString()}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authorization
      },
    );
    if (checkMissingToken(response.statusCode)) {
      notifyListeners();
    } else if (response.statusCode == 200) {
      final gmJson = json.decode(response.body);
      copy(gmJson);
    }
  }
}
