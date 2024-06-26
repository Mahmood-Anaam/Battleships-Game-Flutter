import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';

class GameServices {

  late Map<String,String> headers;

  GameServices({required String authorization}){
    headers = {
      'Content-Type': 'application/json',
      'Authorization': authorization
    };
  }

  Future<http.Response> getGames() async {
    final response = await http.get(AppConfig.gamesUrl, headers: headers);
    return response;
  }

  Future<http.Response> getGame(int gameId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.gamesUrl.toString()}/$gameId'),
      headers: headers,
    );
    return response;
  }

  Future<http.Response> newGame(List<String> ships, String? ai) async {
    final response = await http.post(AppConfig.gamesUrl,
        headers: headers,
        body: jsonEncode({'ships': ships, if (ai != null) 'ai': ai}));
    return response;
  }

  Future<http.Response> playGame(int gameId, String shot) async {
    final response = await http.put(
        Uri.parse('${AppConfig.gamesUrl.toString()}/$gameId'),
        headers: headers,
        body: jsonEncode({'shot': shot}));
    return response;
  }

  Future<http.Response> cancelGame(int gameId) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.gamesUrl.toString()}/$gameId'),
      headers: headers,
    );

    return response;
  }
}

// final gamesJson = json.decode(response.body) as List;
// final games = gamesJson.map((e) => Game.fromJson(e)).toList();
// return games;

// bool checkMissingToken(http.Response response) {
//   return response.statusCode == 401;
// }
