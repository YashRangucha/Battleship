// lib/views/registration_page.dart

import 'package:flutter/material.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  Future<void> registerUser(String username, String password) async {
    // TODO: Implement HTTP POST request to register endpoint
    // Use the http package to send a request to the register endpoint
    // Handle the response accordingly (store the token, navigate to the next screen, show an error message, etc.)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                registerUser(
                    'username', 'password'); // Replace with actual user input
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
