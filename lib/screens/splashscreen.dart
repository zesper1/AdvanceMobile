import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/providers/auth_provider.dart'; // Make sure this path is correct
import 'package:panot/screens/login.dart'; // Make sure this path is correct
import 'package:panot/screens/seller/seller_home.dart';
import 'package:panot/screens/user/user_shops_screen.dart'; // Import student home

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
          switch (profile.role) {
            case 'seller':
              // If the role is 'seller', navigate to the seller's home screen.
              return SellerHomeScreen(
                sellerId: profile.id,
                sellerName: profile.fullName,
              );
            case 'student':
              // If the role is 'student', navigate to the student's home screen.
              return const HomeScreen(); // Adjust if it needs parameters
            default:
              // If the role is unknown or null, default to the login screen as a fallback.
              print('Unknown role: ${profile.role}, defaulting to login.');
              return const LoginScreen();
          }
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
        print('Auth Error: $error');
        return const LoginScreen();
      },
    );
  }
}
