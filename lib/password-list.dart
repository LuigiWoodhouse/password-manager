import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

class PasswordList extends StatefulWidget {
  const PasswordList({super.key});

  @override
  State<PasswordList> createState() => _PasswordListState();
}

class _PasswordListState extends State<PasswordList> {
  Map<String, Map<String, String>> _passwords = {};
  Map<String, bool> _visibility = {};

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
          Map<String, dynamic> rawPasswords = jsonDecode(passwordsJson);
          _passwords = rawPasswords.map((key, value) => MapEntry(
                key,
                Map<String, String>.from(value),
              ));
          _visibility = {for (var key in _passwords.keys) key: false};
        });
      }
    } catch (e) {
      print('Error loading passwords: $e');
    }
  }

  Future<void> _savePasswords() async {
    try {
      String passwordsJson = jsonEncode(_passwords);
      await _secureStorage.write(key: 'passwords', value: passwordsJson);
    } catch (e) {
      print('Error saving passwords: $e');
    }
  }

  void _removePassword(String name) {
    setState(() {
      _passwords.remove(name);
      _visibility.remove(name);
    });
    _savePasswords();
  }

  void _copyToClipboard(String password) {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _passwords.length,
      itemBuilder: (context, index) {
        String name = _passwords.keys.elementAt(index);
        String password = _passwords[name]!['value']!;
        String timestamp = _passwords[name]!['timestamp']!;
        bool isVisible = _visibility[name] ?? false;

        return ListTile(
          title: Text(name, style: TextStyle(fontSize: 12.0)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isVisible ? password : '••••••••',style: TextStyle(fontSize: 8.0)),
              SizedBox(height: 4.0), // Adjust space between password and timestamp
              Text(
                '($timestamp)',
                style: TextStyle(fontSize: 6.0, color: Colors.grey), // Adjust timestamp style
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, size: 13.0),
                onPressed: () {
                  setState(() {
                    _visibility[name] = !isVisible;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 13.0),
                onPressed: () => _copyToClipboard(password),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 13.0),
                onPressed: () => _removePassword(name),
              ),
            ],
          ),
        );
      },
    );
  }
}
