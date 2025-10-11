import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panot/providers/category_provider.dart';
import 'package:panot/providers/product_provider.dart';
import 'package:panot/providers/seller_shop_provider.dart';
import 'package:panot/theme/app_theme.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  final int shopId;
  const AddProductDialog({super.key, required this.shopId});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  int? _selectedSubcategoryId; // <-- ADD THIS LINE

  XFile? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  // In lib/screens/seller/widgets/add_product_dialog.dart

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image for the product.')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // ✅ MODIFIED: Pass the subcategoryId to the addProduct method
        await ref.read(productProvider(widget.shopId).notifier).addProduct(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              price: double.parse(_priceController.text.trim()),
              quantity: int.parse(_quantityController.text.trim()),
              imageFile: _imageFile!,
              subcategoryId: _selectedSubcategoryId, // This value comes from your dropdown
            );

        if (mounted) {
          Navigator.of(context).pop(); // Close dialog on success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add product: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subcategoriesAsync = ref.watch(shopSubcategoriesProvider(widget.shopId));

    return AlertDialog(
      title: const Text('Add New Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: _imageFile == null
                        ? const Center(child: Icon(Icons.add_a_photo, color: Colors.grey))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                                : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              // --- NEW SUBCATEGORY DROPDOWN ---
              subcategoriesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Loading categories...'),
                ),
                error: (err, stack) => const Text('Could not load categories'),
                data: (subcategories) {
                  return DropdownButtonFormField<int?>(
                    value: _selectedSubcategoryId,
                    hint: const Text('Select Subcategory'),
                    isExpanded: true,
                    items: subcategories.map((sub) {
                      return DropdownMenuItem<int>(
                        value: sub.id,
                        child: Text(sub.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubcategoryId = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a subcategory' : null,
                  );
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price', prefixText: '₱ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a price';
                  if (double.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Initial Quantity / Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a quantity';
                  if (int.tryParse(value) == null) return 'Enter a valid whole number';
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submitForm,
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryColor),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add Product'),
        ),
      ],
    );
  }
}