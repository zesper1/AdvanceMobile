// MODIFIED: Added import for Riverpod and your provider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/providers/auth_provider.dart';
import '../screens/user/user_shops_screen.dart'; // This will eventually be replaced by the splash screen's logic
import '../theme/app_theme.dart';
import '../screens/user/user_shops_screen.dart';
import '../screens/seller/seller_home.dart'; // ADD THIS IMPORT
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
                Image.asset('assets/bb.jpg', height: 180),
                const SizedBox(height: 15),
                const Text('Welcome Nationalian!',
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                const Text('Your campus canteen daily food menu',
                    style: TextStyle(
                        fontSize: 16, color: AppTheme.subtleTextColor)),
                const SizedBox(height: 30),
                Card(
                  elevation: 8.0,
                  shadowColor: AppTheme.primaryColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32.0),
                    // MODIFIED: Pass controllers and sign-in function to the form
                    child: _buildLoginForm(context, authState.isLoading),
                  ),
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
        const RoleDropdown(),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
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
            onPressed: isLoading ? null : _signIn,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
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
        const SizedBox(height: 12),

        // 👇 ADD THIS: Quick Access Section
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.subtleTextColor,
          ),
        ),
        const SizedBox(height: 8),

        // 👇 USER END Button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(color: AppTheme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'USER VIEW',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // 👇 SELLER VIEW Button
        Container(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Navigate to seller home screen with a demo seller ID and name
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SellerHomeScreen(
                    sellerId: 'demo_seller_001',
                    sellerName: 'Ate Smol', // Pass actual seller name
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accentColor,
              side: BorderSide(color: AppTheme.accentColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'SELLER VIEW',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
