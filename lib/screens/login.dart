// MODIFIED: Added import for Riverpod and your provider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/providers/auth_provider.dart';

import '../screens/seller/seller_home.dart'; // This will eventually be replaced by the splash screen's logic
import '../theme/app_theme.dart';
import 'register.dart';

// MODIFIED: Converted to ConsumerStatefulWidget
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // NEW: Add controllers for the text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // NEW: Clean up controllers when the widget is disposed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // NEW: Function to handle the sign-in logic
  Future<void> _signIn() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Call the signIn method from our notifier
    await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    // After attempting sign-in, check if there's an error
    // We check `mounted` to ensure the widget is still in the tree
    if (ref.read(authNotifierProvider).hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authNotifierProvider).error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
    // No need for success navigation here, the SplashScreen will handle it!
  }

  @override
  Widget build(BuildContext context) {
    // NEW: Watch the provider to react to loading states
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Container(
        // ... (Your background decoration remains the same)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              Color(0xFFE3F2FD),
            ],
          ),
        ),
       child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/NU-Dine.png', height: 180),
                const SizedBox(height: 15),
                const Text(
                  'Welcome Nationalian!',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Your campus canteen daily food menu',
                  style: TextStyle(fontSize: 16, color: AppTheme.subtleTextColor),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 8.0,
                  shadowColor: AppTheme.primaryColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: _buildLoginForm(context, authState.isLoading),
                  ),
                ),
                const SizedBox(height: 20),
                // Add the button to navigate to SellerHomeScreen (temporary UI)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
                    );
                  },
                  child: const Text('Open Seller Dashboard Temporarily'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Align(
          alignment: Alignment.center,
          child: Text('Login',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 24),
        // Note: RoleDropdown logic is not yet connected.
        const RoleDropdown(),
        const SizedBox(height: 16),
        // MODIFIED: Use controller for Email Field
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        // MODIFIED: Use controller for Password Field
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            // MODIFIED: Call _signIn and disable button while loading
            onPressed: isLoading ? null : _signIn,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Sign In'),
          ),
        ),
        _buildAuthSwitch(
          context: context,
          label: "Don't have an account?",
          buttonText: 'Register',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
        ),
      ],
    );
  }
  
  // _buildAuthSwitch remains the same...
  Widget _buildAuthSwitch({
    required BuildContext context,
    required String label,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.subtleTextColor)),
        TextButton(
          onPressed: onTap,
          child: Text(buttonText),
        ),
      ],
    );
  }
}

// RoleDropdown remains the same for now...
class RoleDropdown extends StatefulWidget {
  const RoleDropdown({super.key});
  @override
  State<RoleDropdown> createState() => _RoleDropdownState();
}

class _RoleDropdownState extends State<RoleDropdown> {
  final List<String> _roles = ['Student', 'Seller'];
  String? _selectedRole;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      hint: const Text('Select your role'),
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.person_search_outlined),
      ),
      items: _roles.map((String role) {
        return DropdownMenuItem<String>(value: role, child: Text(role));
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedRole = newValue;
        });
      },
    );
  }
}