// lib/screens/seller/widgets/edit_product_dialog.dart - UPDATED

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panot/models/product_model.dart';
import 'package:panot/providers/product_provider.dart';
import 'package:panot/providers/seller_shop_provider.dart';
import 'package:panot/theme/app_theme.dart';

// --- Constants for a professional and consistent UI ---
const double _kSpacing = 16.0;
const double _kSmallSpacing = 10.0;
const double _kFontSize = 13.0;
const double _kCornerRadius = 16.0;

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
  int? _selectedSubcategoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.productName);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _quantityController =
        TextEditingController(text: widget.product.quantity.toString());
    _isAvailable = widget.product.isAvailable;
    _selectedSubcategoryId = widget.product.subcategoryId;
  }

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
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(productProvider(widget.product.shopId).notifier)
            .updateProduct(
              productId: widget.product.productId,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              price: double.parse(_priceController.text.trim()),
              quantity: int.parse(_quantityController.text.trim()),
              isAvailable: _isAvailable,
              newImageFile: _newImageFile,
              existingImageUrl: widget.product.imageUrl,
              subcategoryId: _selectedSubcategoryId,
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

  // --- Reusable InputDecoration for a consistent look ---
  InputDecoration _buildInputDecoration(String labelText,
      {String prefixText = ''}) {
    return InputDecoration(
      labelText: labelText,
      prefixText: prefixText.isNotEmpty ? prefixText : null,
      labelStyle: const TextStyle(fontSize: _kFontSize, color: Colors.black54),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_kCornerRadius / 2),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_kCornerRadius / 2),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_kCornerRadius / 2),
        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2.0),
      ),
    );
  }

  // --- Helper Widget for TextFormFields ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String prefixText = '',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _kSmallSpacing),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: _kFontSize),
        decoration: _buildInputDecoration(labelText, prefixText: prefixText),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subcategoriesAsync =
        ref.watch(shopSubcategoriesProvider(widget.product.shopId));
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      title: Text(
        'Edit Product',
        style: theme.textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kCornerRadius)),

      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Image Picker ---
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(_kCornerRadius),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1.5),
                      ),
                      child: _newImageFile != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(_kCornerRadius - 1),
                              child: kIsWeb
                                  ? Image.network(_newImageFile!.path,
                                      fit: BoxFit.cover,
                                      width: 110,
                                      height: 110)
                                  : Image.file(File(_newImageFile!.path),
                                      fit: BoxFit.cover,
                                      width: 110,
                                      height: 110),
                            )
                          : (widget.product.imageUrl != null &&
                                  widget.product.imageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(_kCornerRadius - 1),
                                  child: Image.network(
                                    widget.product.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: 110,
                                    height: 110,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.photo_outlined,
                                                color: Colors.grey.shade600,
                                                size: 32),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Current Photo',
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: _kFontSize - 1),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined,
                                          color: Colors.grey.shade600,
                                          size: 32),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Add Photo',
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: _kFontSize - 1),
                                      ),
                                    ],
                                  ),
                                )),
                    ),
                  ),
                ),
                const SizedBox(height: _kSpacing),

                // --- Form Fields ---
                _buildTextField(
                  controller: _nameController,
                  labelText: 'Product Name',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),

                // --- SUBCATEGORY DROPDOWN ---
                Padding(
                  padding: const EdgeInsets.only(bottom: _kSmallSpacing),
                  child: subcategoriesAsync.when(
                    loading: () =>
                        const Center(child: Text('Loading categories...')),
                    error: (err, stack) => const Text(
                        'Could not load categories',
                        style: TextStyle(color: Colors.red)),
                    data: (subcategories) {
                      return DropdownButtonFormField<int?>(
                        value: _selectedSubcategoryId,
                        isExpanded: true,
                        style: TextStyle(
                            fontSize: _kFontSize,
                            color: theme.textTheme.bodyMedium!.color),
                        decoration: _buildInputDecoration('Select Subcategory'),
                        hint: const Text('Select Subcategory',
                            style: TextStyle(fontSize: _kFontSize)),
                        items: subcategories.map((sub) {
                          return DropdownMenuItem<int>(
                            value: sub.id,
                            child: Text(sub.name,
                                style: const TextStyle(fontSize: _kFontSize)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubcategoryId = value;
                          });
                        },
                        validator: (value) => value == null
                            ? 'Please select a subcategory'
                            : null,
                      );
                    },
                  ),
                ),

                _buildTextField(
                  controller: _priceController,
                  labelText: 'Price',
                  prefixText: '₱ ',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter a price';
                    if (double.tryParse(value) == null)
                      return 'Enter a valid number';
                    return null;
                  },
                ),

                _buildTextField(
                  controller: _quantityController,
                  labelText: 'Quantity / Stock',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter a quantity';
                    if (int.tryParse(value) == null)
                      return 'Enter a valid whole number';
                    return null;
                  },
                ),

                _buildTextField(
                  controller: _descriptionController,
                  labelText: 'Description (Optional)',
                  maxLines: 3,
                ),
                const SizedBox(height: _kSpacing),

                // --- Availability Switch ---
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: _kSmallSpacing),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available for purchase',
                        style: TextStyle(
                          fontSize: _kFontSize,
                          color: theme.textTheme.bodyMedium!.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: _isAvailable,
                        onChanged: (value) =>
                            setState(() => _isAvailable = value),
                        activeColor: AppTheme.primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // --- Actions ---
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
                fontSize: _kFontSize,
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold),
          ),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submitForm,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : const Text(
                  'Save Changes',
                  style: TextStyle(
                      fontSize: _kFontSize, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
