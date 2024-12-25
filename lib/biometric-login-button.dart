import 'package:flutter/material.dart';

class BiometricLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BiometricLoginButton({required this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.fingerprint), // Fingerprint icon
      label: const Text(
        'Login with fingerprint',
        style: TextStyle(fontSize: 20),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 42),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Match card border radius
        ),
        backgroundColor: const Color.fromARGB(255, 54, 83, 106),
        foregroundColor: Colors.white,
      ),
    );
  }
}
