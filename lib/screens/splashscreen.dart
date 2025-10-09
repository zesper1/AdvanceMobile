import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/providers/auth_provider.dart'; // Your auth provider
import 'package:panot/screens/login.dart';
import 'package:panot/screens/reset_password_screen.dart'; // Import the new screen
import 'package:panot/screens/seller/seller_home.dart';
import 'package:panot/screens/user/user_shops_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import for AuthChangeEvent

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // NEW: Listen for the password recovery event to trigger navigation
    ref.listen(authStateChangeProvider, (_, next) {
      final event = next.asData?.value.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        // Navigate to the screen where the user can enter a new password
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
        );
      }
    });

    // This part remains the same, watching the final state to decide the screen
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (profile) {
        if (profile != null) {
          switch (profile.role) {
            case 'seller':
              return SellerHomeScreen(
                sellerId: profile.id,
                sellerName: profile.fullName,
              );
            case 'student':
              return const HomeScreen();
            default:
              print('Unknown role: ${profile.role}, defaulting to login.');
              return const LoginScreen();
          }
        }
        return const LoginScreen();
      },
      loading: () {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, stackTrace) {
        print('Auth Error: $error');
        return const LoginScreen();
      },
    );
  }
}