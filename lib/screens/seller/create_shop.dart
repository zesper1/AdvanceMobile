// screens/seller/create_shop.dart - FIXED
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/seller_shop_model.dart';
import '../../providers/seller_shop_provider.dart';
import '../../theme/app_theme.dart';

class CreateShopScreen extends ConsumerStatefulWidget {
  final String sellerId;

  const CreateShopScreen({super.key, required this.sellerId});

  @override
  ConsumerState<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends ConsumerState<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _openingTimeController = TextEditingController();
  final TextEditingController _closingTimeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customCategoryController =
      TextEditingController();

  String _selectedCategory = 'Snack';
  String _imageUrl =
      'https://placehold.co/600x400/FFF4E0/000000?text=Shop+Image';
  List<String> _customCategories = [];

  final List<String> _mainCategories = ['Snack', 'Drink', 'Meal'];

  @override
  void initState() {
    super.initState();
    _openingTimeController.text = '09:00 AM';
    _closingTimeController.text = '10:00 PM';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    _descriptionController.dispose();
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newShop = SellerShop(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        imageUrl: _imageUrl,
        openingTime: _openingTimeController.text,
        closingTime: _closingTimeController.text,
        category: _selectedCategory,
        rating: 0.0,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        sellerId: widget.sellerId,
        status: ShopStatus.Pending,
        customCategories: _customCategories,
        createdAt: DateTime.now(),
      );

      // FIXED: Now using the correct method signature (only one parameter)
      ref.read(sellerShopProvider.notifier).addShop(newShop);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Shop created successfully! Waiting for admin approval.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Create New Shop',
          style: TextStyle(color: AppTheme.textColor),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              _buildImageSection(),
              const SizedBox(height: 24),

              // Shop Name
              _buildFormField(
                controller: _nameController,
                label: 'Shop Name',
                hintText: 'Enter your shop name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a shop name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Operating Hours
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      controller: _openingTimeController,
                      label: 'Opening Time',
                      hintText: '09:00 AM',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter opening time';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      controller: _closingTimeController,
                      label: 'Closing Time',
                      hintText: '10:00 PM',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter closing time';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              _buildFormField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hintText: 'Tell us about your shop...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Main Category
              _buildCategoryDropdown(),
              const SizedBox(height: 24),

              // Custom Categories
              _buildCustomCategoriesSection(),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Shop',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shop Image',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.cardColor,
            image: DecorationImage(
              image: NetworkImage(_imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Edit Image URL'),
                          content: TextField(
                            controller: TextEditingController(text: _imageUrl),
                            onChanged: (value) {
                              setState(() {
                                _imageUrl = value;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Enter image URL',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppTheme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Main Category',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            underline: const SizedBox(),
            items: _mainCategories.map((String category) {
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
        ),
      ],
    );
  }

  Widget _buildCustomCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Custom Categories',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add your own categories for menu items (e.g., Coffee, Frappe, Biscuits)',
          style: TextStyle(
            color: AppTheme.subtleTextColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customCategoryController,
                decoration: InputDecoration(
                  hintText: 'Add a category...',
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryColor, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: _addCustomCategory,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_customCategories.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _customCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return Chip(
                label: Text(category),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeCustomCategory(index),
                backgroundColor: AppTheme.accentColor.withOpacity(0.2),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
