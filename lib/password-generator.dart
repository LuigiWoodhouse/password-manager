import 'package:flutter/material.dart';

class PasswordGenerator extends StatelessWidget {
  final double passwordLength;
  final ValueChanged<double> onLengthChanged;
  final VoidCallback onGenerate;

  const PasswordGenerator({
    super.key,
    required this.passwordLength,
    required this.onLengthChanged,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Password Generator',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Slider(
          value: passwordLength,
          min: 8,
          max: 30,
          divisions: 22,
          label: passwordLength.toInt().toString(),
          onChanged: onLengthChanged,
        ),
        ElevatedButton(
          onPressed: onGenerate,
          child: const Text('Generate Password'),
        ),
      ],
    );
  }
}
