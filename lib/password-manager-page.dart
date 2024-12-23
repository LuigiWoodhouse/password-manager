import 'package:flutter/material.dart';

import 'password-generator.dart';
import 'password-list.dart';


class PasswordManagerPage extends StatelessWidget {
  const PasswordManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            PasswordGenerator(),
            Expanded(child: PasswordList()),
          ],
        ),
      ),
    );
  }
}
