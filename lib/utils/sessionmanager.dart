import 'dart:convert';
import '../models/player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _sessionKey = 'playerKey';

  // Method to check if a user is logged in.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionPlayer = prefs.getString(_sessionKey);
    return sessionPlayer != null;
  }

  // Method to retrieve the session player.
  static Future<Player> getSessionPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    final playerStr = prefs.getString(_sessionKey);
    if (playerStr == null) return Player.anonymous();
    return Player.fromJson(json.decode(playerStr) as Map<String, dynamic>);
  }

  // Method to set the session player.
  static Future<bool> setSessionPlayer(Player player) async {
    final prefs = await SharedPreferences.getInstance();
    if (player.token.isEmpty) return false;
    final playerJson = json.encode(player.toJson());
    return await prefs.setString(_sessionKey, playerJson);
  }

  // Method to clear the session player, effectively logging the user out.
  static Future<bool> clearSessionPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_sessionKey);
  }
}
