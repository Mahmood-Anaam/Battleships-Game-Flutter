import 'dart:convert';
import '../models/player.dart';
import 'gamelist_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/gamelist.dart';
import '../utils/app_config.dart';
import '../utils/sessionmanager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController =
      TextEditingController();
  final TextEditingController passwordController =
      TextEditingController();

  bool usernameValidate = false;
  bool passwordValidate = false;

  Future<void> _auth(
      {required BuildContext context, bool isRegister = true}) async {
    final username = usernameController.text;
    final password = passwordController.text;

    AppConfig.showLoading(context);
    Map<String, String> playerMap = {
      'username': username,
      'password': password,
    };

    final response =
        await http.post(isRegister ? AppConfig.registerUrl : AppConfig.loginUrl,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(playerMap));

    if (!mounted) return;
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      playerMap["token"] = jsonDecode(response.body)['access_token'] as String;
      Player player = Player.fromJson(playerMap);
      await SessionManager.setSessionPlayer(player);
     final games = GameList(player);
     games.loadGames(false);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<GameList>(
                create: (_) => games,
                child: const GameListScreen(),
          )
      ));
    } else {
      final msg = isRegister ? 'Registration failed' : 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  bool fieldsValidation() {
    final String username = usernameController.text;
    final String password = passwordController.text;
    usernameValidate =
        username.isEmpty || username.length < 3 || username.contains(' ');
    passwordValidate =
        password.isEmpty || password.length < 3 || password.contains(' ');
    return usernameValidate || passwordValidate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                errorText: usernameValidate
                    ? "Username must be at least 3 characters long and cannot contain spaces"
                    : null,
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: passwordValidate
                    ? "Password must be at least 3 characters long and cannot contain spaces"
                    : null,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    if (fieldsValidation()) {
                      setState(() {});
                    } else {
                      _auth(context: context, isRegister: false);
                    }
                  },
                  child: const Text('Log in'),
                ),
                TextButton(
                  onPressed: () {
                    if (fieldsValidation()) {
                      setState(() {});
                    } else {
                      _auth(context: context, isRegister: true);
                    }
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
