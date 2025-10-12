// lib/screens/register.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/providers/auth_provider.dart';
import 'package:panot/widgets/policy.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentIdController = TextEditingController();

  String? _selectedRole;
  String? _selectedCourse;
  String? _selectedYearLevel;

  bool _agreedToTerms = false;
  // NEW: State variables to toggle password visibility
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  int _parseYearLevel(String year) {
    switch (year) {
      case '1ST':
        return 1;
      case '2ND':
        return 2;
      case '3RD':
        return 3;
      case '4TH':
        return 4;
      case 'SHS':
        return 0;
      default:
        return 0;
    }
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('You must agree to the terms and conditions to register.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();
    final String role = _selectedRole!.toLowerCase().replaceAll(' ', '_');
    final String studentId = _studentIdController.text.trim();
    final String course = _selectedCourse ?? '';
    final int yearLevel =
        _selectedYearLevel != null ? _parseYearLevel(_selectedYearLevel!) : 0;

    Map<String, dynamic> userMetadata = {
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
    };

    if (role == 'student') {
      userMetadata.addAll({
        'student_id': studentId,
        'course': course,
        'year_level': yearLevel,
      });
    }

    try {
      await ref.read(authNotifierProvider.notifier).signUp(
            email: email,
            password: password,
            metadata: userMetadata,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Registration successful! Please check your email to verify your account.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.backgroundColor, Color(0xFFE3F2FD)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/NU-Dine.png', height: 150),
                const SizedBox(height: 16),
                const Text('Create Your Account',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Card(
                  elevation: 8.0,
                  shadowColor: AppTheme.primaryColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32.0),
                    child: Form(
                      key: _formKey,
                      child: _buildRegisterForm(context, authState.isLoading),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context, bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Sign Up',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        CustomDropdownFormField(
          value: _selectedRole,
          hintText: 'I am a...',
          prefixIcon: Icons.person_search_outlined,
          items: const ['Student', 'Seller'],
          onChanged: (newValue) {
            setState(() {
              _selectedRole = newValue;
            });
          },
          validator: (value) => value == null ? 'Please select a role' : null,
        ),
        const SizedBox(height: 16),
        if (_selectedRole != null) ...[
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
                hintText: 'First Name', prefixIcon: Icon(Icons.person_outline)),
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter your first name'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
                hintText: 'Last Name', prefixIcon: Icon(Icons.person_outline)),
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter your last name'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                hintText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined)),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter your email';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          // MODIFIED: Added password toggle and enhanced validation
          TextFormField(
            controller: _passwordController,
            obscureText: _isPasswordObscured,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters long';
              }
              if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
                return 'Must contain at least one lowercase letter';
              }
              if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                return 'Must contain at least one uppercase letter';
              }
              if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                return 'Must contain at least one number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // MODIFIED: Added password toggle
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _isConfirmPasswordObscured,
            decoration: InputDecoration(
              hintText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordObscured
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please confirm your password';
              if (value != _passwordController.text)
                return 'Passwords do not match';
              return null;
            },
          ),

          if (_selectedRole == 'Student') ...[
            const SizedBox(height: 16),
            // MODIFIED: Added Student ID formatter and validation
            TextFormField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                  hintText: 'Student ID (e.g., 2022-171688)',
                  prefixIcon: Icon(Icons.badge_outlined)),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                StudentIdInputFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Student ID';
                }
                if (!RegExp(r'^\d{4}-\d{6}$').hasMatch(value)) {
                  return 'Format must be YYYY-NNNNNN';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomDropdownFormField(
              value: _selectedCourse,
              hintText: 'College/Department',
              prefixIcon: Icons.school_outlined,
              items: const ['SHS', 'SECA', 'SASE', 'SBMA'],
              onChanged: (newValue) {
                setState(() {
                  _selectedCourse = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a department' : null,
            ),
            const SizedBox(height: 16),
            CustomDropdownFormField(
              value: _selectedYearLevel,
              hintText: 'Year Level',
              prefixIcon: Icons.format_list_numbered,
              items: const ['SHS', '1ST', '2ND', '3RD', '4TH'],
              onChanged: (newValue) {
                setState(() {
                  _selectedYearLevel = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a year level' : null,
            ),
          ],

          const SizedBox(height: 16),
          _buildTermsAndConditions(context),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _signUp,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Create Account'),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildAuthSwitch(
            context: context,
            label: 'Already have an account?',
            buttonText: 'Login',
            onTap: () {
              Navigator.pop(context);
            }),
      ],
    );
  }

  Widget _buildTermsAndConditions(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: (bool? value) {
            setState(() {
              _agreedToTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(
                      color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PolicyPage()));
                    },
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                      color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PolicyPage()));
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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
        TextButton(onPressed: onTap, child: Text(buttonText)),
      ],
    );
  }
}

class CustomDropdownFormField extends StatelessWidget {
  final String? value;
  final String hintText;
  final IconData prefixIcon;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String> validator;

  const CustomDropdownFormField({
    super.key,
    required this.value,
    required this.hintText,
    required this.prefixIcon,
    required this.items,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hintText),
      decoration: InputDecoration(prefixIcon: Icon(prefixIcon)),
      validator: validator,
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}

// NEW: Input formatter for Student ID (e.g., 2022-123456)
class StudentIdInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length > 11) {
      return oldValue;
    }

    var newText = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 4) {
        newText.write('-');
      }
      newText.write(text[i]);
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
