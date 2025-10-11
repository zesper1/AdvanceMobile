// lib/screens/seller/widgets/confirm_delete_dialog.dart

import 'package:flutter/material.dart';

/// Shows a confirmation dialog for deleting an item.
Future<bool?> showConfirmDeleteDialog({
  required BuildContext context,
  required String itemName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to permanently delete "$itemName"? This action cannot be undone.'),
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
              backgroundColor: Colors.red.shade700,
            ),
            child: const Text('Delete'),
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