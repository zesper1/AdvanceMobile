import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/seller_shop_model.dart';
import '../../providers/seller_shop_provider.dart';
import '../../models/category_model.dart'
    as categ; // Import your Category and Subcategory models
import '../../providers/category_provider.dart'; // Import your category providers

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

  // CHANGED: To hold selected Category object
  categ.Category? _selectedMainCategory;
  // CHANGED: To hold selected Subcategory objects (for their names)
  List<categ.Subcategory> _selectedSubcategories = [];

  bool _isLoading = false;
  bool _isUpdateMode = false;
  bool _isInit = true; // Flag to run update-mode logic only once

  @override
  void initState() {
    super.initState();
    // We only pre-fill data here if it's NOT dependent on async providers
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
    if (_isInit) {
      if (_isUpdateMode) {
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
                  } catch (_) {} // Ignore if not found
                }
                // Update state after build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _selectedMainCategory = preselectedCategory;
                      _selectedSubcategories = preselectedSubs;
                    });
                  }
                });
              });
            } catch (_) {/* Category not found, do nothing */}
          }
        });
      }
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
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
        // --- UPDATE LOGIC ---

        // Create a list of subcategory IDs to send for the update.
        final List<int> subcategoryIdsToSubmit =
            _selectedSubcategories.map((e) => e.id).toList();
        print(subcategoryIdsToSubmit);
        await ref.read(sellerShopProvider.notifier).updateShop(
              shopId: widget.shopToUpdate!.id,
              shopName: _nameController.text,
              description: _descriptionController.text,
              newImageFile: _pickedImage ??
                  (widget.shopToUpdate!.imageUrl == null ? _pickedImage : null),
              openingTime: _openingTime,
              closingTime: _closingTime,
              categoryId:
                  _selectedMainCategory!.id, // CORRECTED: Pass the integer ID
              subcategoryIds:
                  subcategoryIdsToSubmit, // CORRECTED: Pass the list of integer IDs
            );
      } else {
        // --- CREATE LOGIC ---

        // For creation, the RPC is smart enough to look up names.
        final List<int> subcategoryIdsToSubmit =
            _selectedSubcategories.map((e) => e.id).toList();

        await ref.read(sellerShopProvider.notifier).addShop(
              shopName: _nameController.text,
              description: _descriptionController.text,
              imageFile: _pickedImage!,
              openingTime: _openingTime,
              closingTime: _closingTime,
              categoryName:
                  _selectedMainCategory!.id, // CORRECTED: Pass the string name
              subcategoryNames:
                  subcategoryIdsToSubmit, // This remains a list of names for 'create'
            );
      }

      final state = ref.read(sellerShopProvider);
      if (state.hasError) {
        throw state.error!;
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
                'Failed to ${_isUpdateMode ? 'update' : 'create'} shop: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the main categories provider at the top of the build method.
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 4.0,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.95),
          flexibleSpace: Stack(
            fit: StackFit.expand,
            children: [
              // ✅ Background image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/NU-Dine.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // ✅ Semi-transparent overlay
              Container(
                color: Colors.black.withOpacity(0.3),
              ),

              // ✅ Title + Back button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // ✅ Floating circular back button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Theme.of(context).colorScheme.primary,
                            size: 22,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _isUpdateMode ? 'Update Shop' : 'Create New Shop',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 48), // to balance layout with back button
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildFormField(
                controller: _nameController,
                labelText: 'Shop Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a shop name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _descriptionController,
                labelText: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTimePickerField(
                context,
                'Opening Time',
                _openingTime,
                true,
              ),
              const SizedBox(height: 16),
              _buildTimePickerField(
                context,
                'Closing Time',
                _closingTime,
                false,
              ),
              const SizedBox(height: 24),

              // --- MAIN CATEGORY DROPDOWN ---
              Text('Main Category',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              categoriesAsyncValue.when(
                data: (categories) {
                  // Safely set the default for create mode ONLY if it hasn't been set yet.
                  if (!_isUpdateMode &&
                      _selectedMainCategory == null &&
                      categories.isNotEmpty) {
                    // This schedules the state update for after the build is complete.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _selectedMainCategory = categories.first;
                        });
                      }
                    });
                  }

                  if (categories.isEmpty) {
                    return const Text(
                        'No categories available. Please add some in the database.');
                  }

                  return DropdownButtonFormField<categ.Category>(
                    value:
                        _selectedMainCategory, // No "!" needed, the value can be null.
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Select Main Category',
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem<categ.Category>(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (categ.Category? newValue) {
                      setState(() {
                        _selectedMainCategory = newValue;
                        _selectedSubcategories =
                            []; // Clear subcategories when main category changes
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a main category.' : null,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error loading categories: $err'),
              ),
              const SizedBox(height: 24),

              // --- SUBCATEGORY SELECTION ---
              Text('Subcategories',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_selectedMainCategory == null)
                const Text(
                    'Please select a main category to see subcategories.')
              else
                // If a main category is selected, watch and display the subcategories.
                ref
                    .watch(subcategoriesProvider(_selectedMainCategory!.id))
                    .when(
                      data: (subcategories) {
                        if (subcategories.isEmpty) {
                          return const Text(
                              'No subcategories found for this category.');
                        }
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: subcategories.map((sub) {
                            final isSelected = _selectedSubcategories
                                .any((s) => s.id == sub.id);
                            return FilterChip(
                              label: Text(sub.name),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedSubcategories.add(sub);
                                  } else {
                                    _selectedSubcategories
                                        .removeWhere((s) => s.id == sub.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) =>
                          Text('Error loading subcategories: $err'),
                    ),
              const SizedBox(height: 32),

              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isUpdateMode ? 'Update Shop' : 'Create Shop',
                            style: const TextStyle(fontSize: 18),
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
        Text('Shop Image', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to select image',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  if (_pickedImage != null || _existingImageUrl != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: _pickImage,
                        ),
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
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildTimePickerField(
    BuildContext context,
    String labelText,
    TimeOfDay time,
    bool isOpening,
  ) {
    return GestureDetector(
      onTap: () => _selectTime(context, isOpening),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.access_time),
          ),
          controller: TextEditingController(text: time.format(context)),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a time.';
            }
            return null;
          },
        ),
      ),
    );
  }
}
