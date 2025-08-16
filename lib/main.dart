import 'package:flutter/material.dart';
import './auth/screens/login.dart'; // <-- Import the login screen
import 'theme/app_theme.dart'; // <-- Import your theme

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food App',
      theme: AppTheme.lightTheme, // <-- Apply your custom theme
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(), // <-- Set LoginScreen as the home screen
    );
  }
}
