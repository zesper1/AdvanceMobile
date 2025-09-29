import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // NEW: Import Supabase
import 'package:url_strategy/url_strategy.dart';
import 'screens/splashscreen.dart'; // NEW: Import the splash screen
import 'theme/app_theme.dart';

// MODIFIED: main is now async
Future<void> main() async {
  // NEW: Ensure Flutter bindings are initialized before calling Supabase
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  // NEW: Initialize Supabase connection
  // IMPORTANT: Replace with your actual Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'https://suikndehzeywnvlmjtvr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1aWtuZGVoemV5d252bG1qdHZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU0NzQ2MTYsImV4cCI6MjA3MTA1MDYxNn0.X2-kGdE8GvCoV5yCl9UgXHLnO-DGgcPU0Drwun63D9I',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NU-Dine',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // MODIFIED: The home is now the SplashScreen
      // It will decide whether to show LoginScreen or HomePage
      home: const SplashScreen(),
    );
  }
}