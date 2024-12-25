import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'password-generator.dart';
import 'password-list.dart';
import 'password-storage.dart';
import 'password-utils.dart';

class PasswordManagerPage extends StatefulWidget {
  const PasswordManagerPage({super.key});

  @override
  _PasswordManagerPageState createState() => _PasswordManagerPageState();
}

class _PasswordManagerPageState extends State<PasswordManagerPage> {
  Map<String, Map<String, String>> _passwords = {};
  Map<String, bool> _visibility = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  double _passwordLength = 8;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    Map<String, Map<String, String>> passwords =
        await PasswordStorage.loadPasswords();
    setState(() {
      _passwords = passwords;
      _visibility = {for (var key in passwords.keys) key: false};
    });
  }

  Future<void> _savePasswords() async {
    await PasswordStorage.savePasswords(_passwords);
  }

  void _generatePassword() {
    String newPassword =
        PasswordUtils.generateRandomPassword(_passwordLength.toInt());
    setState(() {
      _passwordController.text = newPassword;
    });
  }

  void _addPassword() {
    String name = _nameController.text.trim();
    String password = _passwordController.text.trim();
    String timestamp =
        DateFormat('EEE MMMM d, yyyy hh:mm:ss a').format(DateTime.now());

    if (name.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _passwords[name] = {'value': password, 'timestamp': timestamp};
        _visibility[name] = false;
        _nameController.clear();
        _passwordController.clear();
      });
      _savePasswords();
    }
  }

  void _removePassword(String name) {
    setState(() {
      _passwords.remove(name);
      _visibility.remove(name);
    });
    _savePasswords();
  }

  void _updatePassword(String name) {
    _passwordController.text = _passwords[name]!['value']!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Password'),
        content: TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'New Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _passwords[name]!['value'] = _passwordController.text.trim();
                _passwords[name]!['timestamp'] =
                    DateFormat('EEE MMMM d, yyyy hh:mm:ss a')
                        .format(DateTime.now());
                _passwordController.clear();
              });
              _savePasswords();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String password) {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PasswordGenerator(
              passwordLength: _passwordLength,
              onLengthChanged: (value) {
                setState(() {
                  _passwordLength = value;
                });
              },
              onGenerate: _generatePassword,
            ),
            const SizedBox(height: 10),

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
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
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

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addPassword,
              child: const Text('Save Password'),
            ),
            Expanded(
              child: PasswordList(
                passwords: _passwords,
                visibility: _visibility,
                onToggleVisibility: (name) {
                  setState(() {
                    _visibility[name] = !_visibility[name]!;
                  });
                },
                onRemove: _removePassword,
                onCopy: _copyToClipboard,
                onUpdate: _updatePassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
