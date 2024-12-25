import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PasswordStorage {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<Map<String, Map<String, String>>> loadPasswords() async {
    try {
      String? passwordsJson = await _secureStorage.read(key: 'passwords');
      if (passwordsJson != null) {
        Map<String, dynamic> rawPasswords = jsonDecode(passwordsJson);
        return rawPasswords.map((key, value) {
          return MapEntry(key, Map<String, String>.from(value));
        });
      }
    } catch (e) {
      print('Error loading passwords securely: $e');
    }
    return {};
  }

  static Future<void> savePasswords(Map<String, Map<String, String>> passwords) async {
    try {
      String passwordsJson = jsonEncode(passwords);
      await _secureStorage.write(key: 'passwords', value: passwordsJson);
    } catch (e) {
      print('Error saving passwords securely: $e');
    }
  }
}
