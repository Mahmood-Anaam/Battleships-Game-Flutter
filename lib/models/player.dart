class Player {
  final String username;
  final String password;
  final String token;

  Player({required this.username, required this.password, required this.token});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      username: json['username'] as String,
      password: json['password'] as String,
      token: json['token'] as String,
    );
  }

  factory Player.anonymous() {
    return Player(
      username: '',
      password: '',
      token: '',
    );
  }

  bool isAnonymous() {
    return username.isEmpty && password.isEmpty && token.isEmpty;
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password, 'token': token};
  }
}
