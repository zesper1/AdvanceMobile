import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/providers/auth_provider.dart'; // Make sure this path is correct
import 'package:panot/screens/home_screen.dart';     // Make sure this path is correct
import 'package:panot/screens/login.dart';          // Make sure this path is correct

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state of the AuthNotifier
    final authState = ref.watch(authNotifierProvider);

    // Use .when() to handle loading, error, and data states elegantly
    return authState.when(
      data: (profile) {
        // If profile data is not null, the user is logged in
        if (profile != null) {
          return const HomePage();
        }
        // If profile is null, the user is logged out
        return const LoginScreen();
      },
      loading: () {
        // Show a loading screen while checking auth state
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, stackTrace) {
        // If something goes wrong, show an error and default to the LoginScreen
        // You could also create a dedicated error screen
        print('Auth Error: $error');
        return const LoginScreen();
      },
    );
  }
}