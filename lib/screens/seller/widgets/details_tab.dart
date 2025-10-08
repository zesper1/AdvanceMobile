import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/seller_shop_model.dart';
import '../../../theme/app_theme.dart';

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
  late TextEditingController _customCategoryController;

  late String _selectedCategory;
  late List<String> _customCategories;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shop.name);
    _descriptionController =
        TextEditingController(text: widget.shop.description ?? '');
    _openingTimeController =
        TextEditingController(text: widget.shop.openingTime);
    _closingTimeController =
        TextEditingController(text: widget.shop.closingTime);
    _customCategoryController = TextEditingController();
    _selectedCategory = widget.shop.category;
    _customCategories = List.from(widget.shop.customCategories);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _addCustomCategory() {
    if (_customCategoryController.text.isNotEmpty) {
      setState(() {
        _customCategories.add(_customCategoryController.text);
        _customCategoryController.clear();
      });
    }
  }

  void _removeCustomCategory(int index) {
    setState(() {
      _customCategories.removeAt(index);
    });
  }

  void _saveChanges() {
    // Update shop logic here
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shop details updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    int maxLines = 1,
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
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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

  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
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
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textColor),
                    items: ['Snack', 'Drink', 'Meal'].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                )
              : Row(
                  children: [
                    Icon(Icons.category,
                        size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      _selectedCategory,
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

  Widget _buildCustomCategoriesSection() {
    if (!_isEditing && _customCategories.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custom Categories',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (_isEditing) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customCategoryController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Add a category...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    onPressed: _addCustomCategory,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (_customCategories.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _customCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                return Chip(
                  label: Text(category, style: const TextStyle(fontSize: 11)),
                  deleteIcon:
                      _isEditing ? const Icon(Icons.close, size: 14) : null,
                  onDeleted:
                      _isEditing ? () => _removeCustomCategory(index) : null,
                  backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                );
              }).toList(),
            ),
          ] else if (!_isEditing) ...[
            const Text(
              'No custom categories',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isEditing ? Icons.save : Icons.edit,
                          size: 20,
                          color: AppTheme.primaryColor,
                        ),
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
                  _buildEditableField(
                    label: 'Shop Name',
                    controller: _nameController,
                    icon: Icons.store,
                  ),
                  _buildCategorySection(),
                  _buildEditableField(
                    label: 'Description',
                    controller: _descriptionController,
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  _buildEditableField(
                    label: 'Opening Time',
                    controller: _openingTimeController,
                    icon: Icons.access_time,
                  ),
                  _buildEditableField(
                    label: 'Closing Time',
                    controller: _closingTimeController,
                    icon: Icons.access_time,
                  ),
                  _buildCustomCategoriesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
