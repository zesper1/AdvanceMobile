// lib/screens/seller/widgets/edit_product_dialog.dart - UPDATED

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panot/models/product_model.dart';
import 'package:panot/providers/product_provider.dart';
import 'package:panot/providers/seller_shop_provider.dart'; // Import for subcategories
import 'package:panot/theme/app_theme.dart';

class EditProductDialog extends ConsumerStatefulWidget {
  final Product product;
  const EditProductDialog({super.key, required this.product});

  @override
  ConsumerState<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends ConsumerState<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;

  XFile? _newImageFile;
  bool _isAvailable = true;
  bool _isLoading = false;
  int? _selectedSubcategoryId; // State for the dropdown selection

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.productName);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _quantityController = TextEditingController(text: widget.product.quantity.toString());
    _isAvailable = widget.product.isAvailable;
    // Pre-select the product's current subcategory in the dropdown
    _selectedSubcategoryId = widget.product.subcategoryId;
  }

  // ... (dispose and _pickImage methods are unchanged) ...
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
        _newImageFile = pickedFile;
      });
    }
  }


  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref.read(productProvider(widget.product.shopId).notifier).updateProduct(
              productId: widget.product.productId,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              price: double.parse(_priceController.text.trim()),
              quantity: int.parse(_quantityController.text.trim()),
              isAvailable: _isAvailable,
              newImageFile: _newImageFile,
              existingImageUrl: widget.product.imageUrl,
              subcategoryId: _selectedSubcategoryId, // Pass the selected ID
            );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update product: $e')),
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
    // Fetch the subcategories available for this shop
    final subcategoriesAsync = ref.watch(shopSubcategoriesProvider(widget.product.shopId));

    return AlertDialog(
      title: const Text('Edit Product'),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _newImageFile != null
                          ? (kIsWeb
                              ? Image.network(_newImageFile!.path, fit: BoxFit.cover)
                              : Image.file(File(_newImageFile!.path), fit: BoxFit.cover))
                          : (widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty
                              ? Image.network(widget.product.imageUrl!, fit: BoxFit.cover)
                              : const Center(child: Icon(Icons.add_a_photo, color: Colors.grey))),
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

              // --- SUBCATEGORY DROPDOWN ---
              subcategoriesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(child: Text('Loading categories...')),
                ),
                error: (err, stack) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Could not load categories', style: TextStyle(color: Colors.red)),
                ),
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
                decoration: const InputDecoration(labelText: 'Quantity / Stock'),
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
              const SizedBox(height: 16),

              // Availability Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Available for purchase', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: _isAvailable,
                    onChanged: (value) => setState(() => _isAvailable = value),
                    activeColor: AppTheme.primaryColor,
                  ),
                ],
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
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}