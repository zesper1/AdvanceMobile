import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- Import Riverpod
import './auth/screens/login.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      // <-- Wrap the whole app here
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
