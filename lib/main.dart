import 'package:flutter/material.dart';
import 'login.dart';
import 'password-manager-page.dart'; // Keep the PasswordManagerPage import

void main() {
  runApp(const PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  const PasswordManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Password Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Define the initial route
      routes: {
        '/': (context) => const LoginPage(), // LoginPage as the initial screen
        '/home': (context) => const PasswordManagerPage(), // PasswordManagerPage for after login
      },
    );
  }
}
