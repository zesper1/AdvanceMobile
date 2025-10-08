import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/seller_shop_model.dart';
import '../../providers/seller_shop_provider.dart';
import '../../models/category_model.dart' as categ;
import '../../providers/category_provider.dart';

class CreateShopScreen extends ConsumerStatefulWidget {
  final SellerShop? shopToUpdate;

  const CreateShopScreen({super.key, this.shopToUpdate});

  @override
  ConsumerState<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends ConsumerState<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  XFile? _pickedImage;
  String? _existingImageUrl;
  TimeOfDay _openingTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 22, minute: 0);

  categ.Category? _selectedMainCategory;
  List<categ.Subcategory> _selectedSubcategories = [];

  bool _isLoading = false;
  bool _isUpdateMode = false;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    if (widget.shopToUpdate != null) {
      _isUpdateMode = true;
      final shop = widget.shopToUpdate!;
      _nameController.text = shop.name;
      _descriptionController.text = shop.description ?? '';
      _existingImageUrl = shop.imageUrl;

      TimeOfDay parseTime(String time) {
        final parts = time.split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }

      _openingTime = parseTime(shop.openingTime);
      _closingTime = parseTime(shop.closingTime);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit && _isUpdateMode) {
      final categoriesAsync = ref.watch(categoriesProvider);
      categoriesAsync.whenData((categories) {
        if (categories.isNotEmpty) {
          try {
            final preselectedCategory = categories
                .firstWhere((c) => c.name == widget.shopToUpdate!.category);
            final preselectedSubcategoriesFuture =
                ref.watch(subcategoriesProvider(preselectedCategory.id));

            preselectedSubcategoriesFuture.whenData((subcategories) {
              final List<categ.Subcategory> preselectedSubs = [];
              for (var name in widget.shopToUpdate!.customCategories) {
                try {
                  final sub = subcategories.firstWhere((s) => s.name == name);
                  preselectedSubs.add(sub);
                } catch (_) {}
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _selectedMainCategory = preselectedCategory;
                    _selectedSubcategories = preselectedSubs;
                  });
                }
              });
            });
          } catch (_) {}
        }
      });
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isOpening) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? _openingTime : _closingTime,
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMainCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a main category.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedSubcategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one subcategory.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_pickedImage == null && _existingImageUrl == null && !_isUpdateMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a shop image.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isUpdateMode) {
        await ref.read(sellerShopProvider.notifier).updateShop(
              shopId: widget.shopToUpdate!.id,
              shopName: _nameController.text,
              description: _descriptionController.text,
              newImageFile: _pickedImage ??
                  (widget.shopToUpdate!.imageUrl == null ? _pickedImage : null),
              openingTime: _openingTime,
              closingTime: _closingTime,
              categoryId: _selectedMainCategory!.id,
              subcategoryIds: _selectedSubcategories.map((e) => e.id).toList(),
            );
      } else {
        await ref.read(sellerShopProvider.notifier).addShop(
              shopName: _nameController.text,
              description: _descriptionController.text,
              imageFile: _pickedImage!,
              openingTime: _openingTime,
              closingTime: _closingTime,
              categoryName: _selectedMainCategory!.id,
              subcategoryNames:
                  _selectedSubcategories.map((e) => e.id).toList(),
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isUpdateMode
                ? 'Shop updated successfully!'
                : 'Shop created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to ${_isUpdateMode ? 'update' : 'create'} shop: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(
          _isUpdateMode ? 'Update Shop' : 'Create Shop',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white, // ✅ Force white title
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // ✅ White icon, no background
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: Form(
          key: _formKey,
          child: DefaultTextStyle(
            style:
                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(),
                const SizedBox(height: 20),
                _buildFormField(
                  controller: _nameController,
                  labelText: 'Shop Name',
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter a shop name.'
                      : null,
                ),
                const SizedBox(height: 14),
                _buildFormField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                _buildTimePickerField(
                    context, 'Opening Time', _openingTime, true),
                const SizedBox(height: 14),
                _buildTimePickerField(
                    context, 'Closing Time', _closingTime, false),
                const SizedBox(height: 20),
                Text('Main Category',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                categoriesAsyncValue.when(
                  data: (categories) {
                    if (!_isUpdateMode &&
                        _selectedMainCategory == null &&
                        categories.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(
                              () => _selectedMainCategory = categories.first);
                        }
                      });
                    }

                    return DropdownButtonFormField<categ.Category>(
                      value: _selectedMainCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Category',
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<categ.Category>(
                          value: category,
                          child: Text(category.name,
                              style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedMainCategory = newValue;
                          _selectedSubcategories.clear();
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a category.' : null,
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error: $err'),
                ),
                const SizedBox(height: 20),
                Text('Subcategories',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                if (_selectedMainCategory == null)
                  const Text('Please select a main category.')
                else
                  ref
                      .watch(subcategoriesProvider(_selectedMainCategory!.id))
                      .when(
                        data: (subs) => Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: subs.map((sub) {
                            final selected = _selectedSubcategories
                                .any((s) => s.id == sub.id);
                            return FilterChip(
                              label: Text(sub.name,
                                  style: const TextStyle(fontSize: 12)),
                              selected: selected,
                              onSelected: (bool sel) {
                                setState(() {
                                  if (sel) {
                                    _selectedSubcategories.add(sub);
                                  } else {
                                    _selectedSubcategories
                                        .removeWhere((s) => s.id == sub.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('Error loading: $err'),
                      ),
                const SizedBox(height: 28),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isUpdateMode ? 'Update Shop' : 'Create Shop'),
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

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shop Image', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_pickedImage != null)
                    kIsWeb
                        ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                        : Image.file(File(_pickedImage!.path),
                            fit: BoxFit.cover)
                  else if (_existingImageUrl != null)
                    Image.network(_existingImageUrl!, fit: BoxFit.cover)
                  else
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt,
                              size: 40, color: Colors.grey[600]),
                          const SizedBox(height: 6),
                          Text('Tap to select image',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 13),
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildTimePickerField(
      BuildContext context, String labelText, TimeOfDay time, bool isOpening) {
    return GestureDetector(
      onTap: () => _selectTime(context, isOpening),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(fontSize: 13),
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.access_time),
          ),
          controller: TextEditingController(text: time.format(context)),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please select a time.' : null,
        ),
      ),
    );
  }
}
