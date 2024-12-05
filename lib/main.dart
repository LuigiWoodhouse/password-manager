import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const PasswordManagerApp());
}

const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

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
      home: const PasswordManagerPage(),
    );
  }
}

class PasswordManagerPage extends StatefulWidget {
  const PasswordManagerPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PasswordManagerPageState createState() => _PasswordManagerPageState();
}

class _PasswordManagerPageState extends State<PasswordManagerPage> {
  Map<String, Map<String, String>> _passwords = {};
  Map<String, bool> _visibility = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  double _passwordLength = 8; // Default password length
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    try {
      String? passwordsJson = await _secureStorage.read(key: 'passwords');
      if (passwordsJson != null) {
        setState(() {
          // Decode JSON and cast nested map correctly
          Map<String, dynamic> rawPasswords = jsonDecode(passwordsJson);
          _passwords = rawPasswords.map((key, value) {
            return MapEntry(
              key,
              Map<String, String>.from(value), // Explicitly cast inner map
            );
          });
          _visibility = {for (var key in _passwords.keys) key: false};
        });
        //print('Passwords loaded securely: $_passwords');
      } else {
        print('No passwords found in secure storage');
      }
    } catch (e) {
      print('Error loading passwords securely: $e');
    }
  }

  Future<void> _savePasswords() async {
    try {
      String passwordsJson = jsonEncode(_passwords);
      await _secureStorage.write(key: 'passwords', value: passwordsJson);
      print('Passwords saved securely: $passwordsJson');
    } catch (e) {
      print('Error saving passwords securely: $e');
    }
  }

  String _generateRandomPassword(int length) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()_+-=[]{}|;:\'",.<>?/`~';
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  void _generatePassword() {
    String newPassword = _generateRandomPassword(_passwordLength.toInt());
    setState(() {
      _passwordController.text = newPassword;
    });
  }

  void _addPassword() {
    String name = _nameController.text.trim();
    String password = _passwordController.text.trim();
    String timestamp = DateFormat('EEE MMMM d, yyyy hh:mm:ss a')
        .format(DateTime.now()); // Format the timestamp

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
                        .format(DateTime.now()); // Update timestamp
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
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Password Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password Value',
                border: const OutlineInputBorder(),
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
              obscureText: !_isPasswordVisible, // Control text visibility
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addPassword,
              child: const Text('Save Password'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _passwords.length,
                itemBuilder: (context, index) {
                  String name = _passwords.keys.elementAt(index);
                  String password = _passwords[name]!['value']!;
                  String timestamp = _passwords[name]!['timestamp']!;
                  bool isVisible = _visibility[name] ?? false;

                  return ListTile(
                    title: Text(name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isVisible ? password : '••••••••'),
                        Text('Added: $timestamp'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(isVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _visibility[name] = !isVisible;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyToClipboard(password),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removePassword(name),
                        ),
                      ],
                    ),
                    onLongPress: () => _updatePassword(name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
