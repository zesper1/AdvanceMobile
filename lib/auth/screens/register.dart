import 'package:flutter/material.dart';
import '../../theme/app_theme.dart'; // Make sure this path is correct

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // The background gradient for the screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              Color(0xFFE3F2FD), // A very light blue
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo and Title
                const Icon(Icons.fastfood_rounded,
                    color: AppTheme.primaryColor, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'Create Your Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Join our campus food community',
                  style:
                      TextStyle(fontSize: 16, color: AppTheme.subtleTextColor),
                ),
                const SizedBox(height: 40),

                // The main card containing the register form
                Card(
                  elevation: 8.0,
                  shadowColor: AppTheme.primaryColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32.0),
                    child: _buildRegisterForm(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the content for the Register form
  Widget _buildRegisterForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Sign Up',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 24),
        const RoleDropdown(),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            hintText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            hintText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Handle registration logic
            },
            child: const Text('Create Account'),
          ),
        ),
        const SizedBox(height: 16),
        _buildAuthSwitch(
          context: context,
          label: 'Already have an account?',
          buttonText: 'Login',
          onTap: () {
            // Navigate back to the login screen
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  // Builds the text button to switch back to the Login screen
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

// A reusable widget for the Role selection dropdown
class RoleDropdown extends StatefulWidget {
  const RoleDropdown({super.key});

  @override
  State<RoleDropdown> createState() => _RoleDropdownState();
}

class _RoleDropdownState extends State<RoleDropdown> {
  final List<String> _roles = ['Student', 'Seller', 'Admin'];
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
        return DropdownMenuItem<String>(
          value: role,
          child: Text(role),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedRole = newValue;
        });
      },
    );
  }
}
