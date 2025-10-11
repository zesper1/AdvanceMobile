// lib/screens/seller/widgets/details_tab.dart - REFACTORED
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/models/category_model.dart';
import 'package:panot/providers/category_provider.dart';
import 'package:panot/providers/seller_shop_provider.dart';
import 'package:panot/models/seller_shop_model.dart';
import 'package:panot/theme/app_theme.dart';

class DetailsTab extends ConsumerStatefulWidget {
  final SellerShop shop;
  const DetailsTab({super.key, required this.shop});

  @override
  ConsumerState<DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends ConsumerState<DetailsTab> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _openingTimeController;
  late TextEditingController _closingTimeController;

  late int _selectedCategoryId;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shop.name);
    _descriptionController = TextEditingController(text: widget.shop.description ?? '');
    // Ensure controllers display the HH:MM format from the model
    _openingTimeController = TextEditingController(text: widget.shop.openingTime);
    _closingTimeController = TextEditingController(text: widget.shop.closingTime);
    _selectedCategoryId = widget.shop.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
  }

  // Helper to format TimeOfDay to HH:MM string for the controller
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // New method to handle time picking and controller update
  Future<void> _pickTime(TextEditingController controller) async {
    final initialTime = controller.text.isNotEmpty
        ? TimeOfDay(
            hour: int.tryParse(controller.text.split(':')[0]) ?? 0,
            minute: int.tryParse(controller.text.split(':')[1]) ?? 0,
          )
        : TimeOfDay.now();

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), // Enforce 24-hour format
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        controller.text = _formatTimeOfDay(pickedTime);
      });
    }
  }


  Future<void> _saveChanges() async {
    // No need for manual time format validation (openTimeParts.length != 2) 
    // if using the time picker, but keep the parsing safe.

    final openTimeParts = _openingTimeController.text.split(':');
    final closeTimeParts = _closingTimeController.text.split(':');

    // Safe parsing to TimeOfDay
    final openingTime = TimeOfDay(
        hour: int.tryParse(openTimeParts[0]) ?? 0, 
        minute: int.tryParse(openTimeParts[1]) ?? 0
    );
    final closingTime = TimeOfDay(
        hour: int.tryParse(closeTimeParts[0]) ?? 0, 
        minute: int.tryParse(closeTimeParts[1]) ?? 0
    );

    try {
      // CALL THE NOTIFIER METHOD TO UPDATE DB AND LOCAL STATE
      await ref.read(sellerShopProvider.notifier).updateBasicShopDetails(
        shopId: int.parse(widget.shop.id),
        shopName: _nameController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategoryId,
        openingTime: openingTime, 
        closingTime: closingTime, 
      );

      setState(() {
        _isEditing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop details updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().contains('Failed') ? e.toString() : 'An unexpected error occurred.'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: Could not load categories. $err')),
      data: (allCategories) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Shop Information',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(_isEditing ? Icons.save : Icons.edit, size: 20, color: AppTheme.primaryColor),
                            onPressed: () {
                              setState(() {
                                if (_isEditing) {
                                  _saveChanges();
                                } else {
                                  _isEditing = true;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildEditableField(label: 'Shop Name', controller: _nameController, icon: Icons.store),
                      _buildCategorySection(allCategories),
                      _buildEditableField(label: 'Description', controller: _descriptionController, icon: Icons.description, maxLines: 3),
                      // Use TimePicker variant for time fields
                      _buildTimeField(label: 'Opening Time', controller: _openingTimeController, icon: Icons.access_time),
                      _buildTimeField(label: 'Closing Time', controller: _closingTimeController, icon: Icons.access_time),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    int maxLines = 1,
    bool readOnly = false, // Added readOnly flag
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: _isEditing
                    ? TextFormField(
                        controller: controller,
                        maxLines: maxLines,
                        readOnly: readOnly, // Apply readOnly here
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      )
                    : Text(
                        controller.text.isEmpty ? 'Not set' : controller.text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // New specialized widget for time fields using Time Picker
  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
  }) {
    // If editing, use the text field variant which is onTap-driven
    if (_isEditing) {
      return GestureDetector(
        onTap: () => _pickTime(controller),
        child: AbsorbPointer( // Prevent manual keyboard input
          child: _buildEditableField(
            label: label,
            controller: controller,
            icon: icon,
            readOnly: true, // Mark as readOnly so the tap handler is the main input
          ),
        ),
      );
    } 
    // If not editing, display as a regular text field
    return _buildEditableField(
      label: label,
      controller: controller,
      icon: icon,
      readOnly: true,
    );
  }

  Widget _buildCategorySection(List<Category> allCategories) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category',
            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          _isEditing
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    decoration: const InputDecoration(border: InputBorder.none),
                    style: const TextStyle(fontSize: 13, color: AppTheme.textColor),
                    items: allCategories.map((Category category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategoryId = newValue;
                        });
                      }
                    },
                    validator: (value) => value == null ? 'Please select a category' : null,
                  ),
                )
              : Row(
                  children: [
                    const Icon(Icons.category, size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      allCategories.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => Category(id: -1, name: "Unknown")).name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}