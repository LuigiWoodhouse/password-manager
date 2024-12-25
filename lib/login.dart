import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import 'biometric-auth-service.dart';
import 'biometric-login-button.dart';
import 'loading-overlay.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool debugMode = true;
  bool _isLoading = false; // Track the loading state

  final LocalAuthentication auth = LocalAuthentication(); // Instantiate LocalAuthentication
  final BiometricAuth _biometricAuth = BiometricAuth();
  bool _canCheckBiometrics = false; // Track biometric support
  bool _isBiometricSupported = false;

  // Trigger biometric authentication directly
  void _authenticateWithBiometrics() async {
    bool isAuthenticated = await _biometricAuth.authenticate();
    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication Failed')),
      );
    }
  }

  // Only show biometric login button if biometrics are supported
  Widget _biometricLoginButton() {
    if (_canCheckBiometrics && _isBiometricSupported) {
      return BiometricLoginButton(
        onPressed: _authenticateWithBiometrics,
      );
    } else {
      return Container(); // Return an empty container if biometrics are not supported
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isBiometricSupported = await auth.isDeviceSupported();
      setState(() {
        _canCheckBiometrics = canCheckBiometrics;
        _isBiometricSupported = isBiometricSupported;
      });
    } catch (e) {
      print('Error checking biometric support: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
      children: [
        SingleChildScrollView( // Wrap main content in a SingleChildScrollView
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100), // Adds top padding to push down the content
    
                _biometricLoginButton(),

              ],
            ),
          ),
        ),
        LoadingOverlay(isLoading: _isLoading), // Overlay on top of other widgets
      ],
      ),
    );
  }
}