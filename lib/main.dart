// main.dart
import 'package:flutter/material.dart';
import '../views/login_status_checker.dart'; // Import your login page file here

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Battleships',
    home: LoginStatusChecker(),
  ));
}
