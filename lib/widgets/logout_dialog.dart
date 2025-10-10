import 'package:flutter/material.dart';
import '../../theme/app_theme.dart'; // Assuming your theme is here

/// Shows a confirmation dialog for logging out.
/// Returns `true` if the user confirms, `false` or `null` otherwise.
Future<bool?> showLogoutConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              // Dismisses the dialog and returns false
              Navigator.of(context).pop(false);
            },
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryColor, // Use your app's theme color
            ),
            child: const Text('Logout'),
            onPressed: () {
              // Dismisses the dialog and returns true
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}