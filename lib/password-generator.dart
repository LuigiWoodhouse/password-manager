import 'dart:math';
import 'package:flutter/material.dart';

class PasswordGenerator extends StatefulWidget {
  const PasswordGenerator({super.key});

  @override
  State<PasswordGenerator> createState() => _PasswordGeneratorState();
}

class _PasswordGeneratorState extends State<PasswordGenerator> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  double _passwordLength = 8;
  bool _isPasswordVisible = false;

  String _generateRandomPassword(int length) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()_+-=[]{}|;:\'",.<>?/`~';
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void _generatePassword() {
    String newPassword = _generateRandomPassword(_passwordLength.toInt());
    setState(() {
      _passwordController.text = newPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Password Generator',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Slider(
          value: _passwordLength,
          min: 8,
          max: 30,
          divisions: 22,
          label: _passwordLength.toInt().toString(),
          onChanged: (value) {
            setState(() {
              _passwordLength = value;
            });
          },
        ),
        ElevatedButton(
          onPressed: _generatePassword,
          child: const Text('Generate Password'),
        ),
        const SizedBox(height: 20), // Added more space here
        // Rounded input field for Password Name
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Password Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0), // Rounded edges
            ),
          ),
        ),
        const SizedBox(height: 20), // Space between input fields
        // Rounded input field for Password Value
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password Value',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0), // Rounded edges
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          obscureText: !_isPasswordVisible,
        ),
      ],
    );
  }
}
