import 'package:flutter/material.dart';
import '../views/login_page.dart';
import '../views/game_list.dart';
import '../utils/session_manager.dart';

class LoginStatusChecker extends StatefulWidget {
  const LoginStatusChecker({super.key});

  @override
  _LoginStatusCheckerState createState() => _LoginStatusCheckerState();
}

class _LoginStatusCheckerState extends State<LoginStatusChecker> {
  bool isLoggedIn = false;
  String username = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      if (await SessionManager.isLoggedIn()) {
        final String loggedInUsername =
            await SessionManager.getLoggedInUsername();
        setState(() {
          isLoggedIn = true;
          username = loggedInUsername;
        });
      } else {
        setState(() {
          isLoggedIn = false;
        });
      }
    } catch (e) {
      print('Error checking login status: $e');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? GameList(username: username) : const LoginPage(),
    );
  }
}
