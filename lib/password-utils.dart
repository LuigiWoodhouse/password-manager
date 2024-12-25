import 'dart:math';

class PasswordUtils {
  static String generateRandomPassword(int length) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()_+-=[]{}|;:\'",.<>?/`~';
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
