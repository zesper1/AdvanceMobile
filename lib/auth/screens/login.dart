import 'package:flutter/material.dart';
import '../../user/user_shops_screen.dart';
import '../../theme/app_theme.dart';
import '../screens/../screens/register.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Image.asset(
                  'assets/NU-Dine.png', // Make sure your logo is in this path
                  height: 180, // Adjust the size as needed
                ),
                const SizedBox(height: 15),
                const Text(
                  'Welcome Nationalian!',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Your campus canteen daily food menu',
                  style:
                      TextStyle(fontSize: 16, color: AppTheme.subtleTextColor),
                ),
                const SizedBox(height: 30),

                // The main card containing the login form
                Card(
                  elevation: 8.0,
                  shadowColor: AppTheme.primaryColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32.0),
                    child: _buildLoginForm(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the content for the Login form
  // Builds the content for the Login form
  Widget _buildLoginForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center, // <-- Center horizontally
      children: [
        const Align(
          alignment: Alignment.center,
          child: Text(
            'Login',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 24),

        // Role Dropdown
        const RoleDropdown(),
        const SizedBox(height: 16),

        // Email Field
        const TextField(
          textAlign: TextAlign.start, // <-- Align input text to the left
          decoration: InputDecoration(
            hintText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),

// Password Field
        const TextField(
          obscureText: true,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
        ),

// Add margin before the button
        const SizedBox(height: 20), // <-- Top margin for Sign In button

// Sign In Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // For now, just navigate directly to UserShopsScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserShopsScreen(),
                ),
              );
            },
            child: const Text('Sign In'),
          ),
        ),
        // Register Switch
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

  // Builds the text button to switch to the Register screen
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
