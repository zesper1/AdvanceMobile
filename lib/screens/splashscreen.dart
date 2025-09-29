// lib/routing.dart or wherever SplashScreen is

import './home_screen.dart';
import './login.dart';
import './seller/seller_home.dart'; // <-- add this
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (profile) {
        if (profile != null) {
          final role = profile['role'];
          if (role == 'seller') {
            return const SellerHomeScreen();
          } else {
            return const HomePage();
          }
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) {
        print('Auth Error: $error');
        return const LoginScreen();
      },
    );
  }
}
