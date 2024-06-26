import 'package:flutter/material.dart';

abstract class AppConfig {
  static final Uri baseUrl = Uri.parse('http://165.227.117.48');
  static final Uri registerUrl = Uri.parse('${baseUrl.toString()}/register');
  static final Uri loginUrl = Uri.parse('${baseUrl.toString()}/login');
  static final Uri gamesUrl = Uri.parse('${baseUrl.toString()}/games');

  static final Uri newGameUrl = Uri.parse('${baseUrl.toString()}/games');

  static void showLoading(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        });
  }
}
