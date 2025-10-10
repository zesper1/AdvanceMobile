// widgets/admin/admin_all_shops_widget.dart
import 'package:flutter/material.dart';
import '../../models/food_stall_model.dart';
import '../../models/seller_shop_model.dart';
import 'food_stall_card.dart';
import '../../theme/app_theme.dart';

class AdminAllShopsWidget extends StatefulWidget {
  final List<SellerShop> allShops;

  const AdminAllShopsWidget({
    super.key,
    required this.allShops,
  });

  @override
  State<AdminAllShopsWidget> createState() => _AdminAllShopsWidgetState();
}

class _AdminAllShopsWidgetState extends State<AdminAllShopsWidget> {
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    // Convert SellerShop to FoodStall for the AdminFoodStallCard
    final foodStalls = widget.allShops
        .map((shop) => FoodStall(
              id: shop.id,
              name: shop.name,
              imageUrl: shop.imageUrl!,
              category: shop.category,
              rating: shop.rating,
              availability: shop.status == ShopStatus.Approved
                  ? AvailabilityStatus.Open
                  : AvailabilityStatus.Closed,
              openingTime: shop.openingTime,
              closingTime: shop.closingTime,
              description: shop.description ?? '',
              location: 'NU Dasma Campus',
              isOpen: shop.status == ShopStatus.Approved,
            ))
        .toList();

    // Apply filters
    List<FoodStall> filteredShops = foodStalls;

    if (_selectedCategory != 'All') {
      filteredShops = filteredShops
          .where((shop) => shop.category == _selectedCategory)
          .toList();
    }

    if (_selectedStatus != 'All') {
      filteredShops = filteredShops.where((shop) {
        if (_selectedStatus == 'Open') {
          return shop.availability == AvailabilityStatus.Open;
        } else if (_selectedStatus == 'Closed') {
          return shop.availability == AvailabilityStatus.Closed ||
              shop.availability == AvailabilityStatus.OnBreak;
        }
        return true;
      }).toList();
    }

    return Column(
      children: [
        // Filter Section
        _buildEnhancedFilterSection(foodStalls),

        // Shops Grid
        Expanded(
          child: filteredShops.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredShops.length,
                  itemBuilder: (context, index) {
                    final shop = filteredShops[index];
                    return AdminFoodStallCard(
                      stall: shop,
                      cardType: 'grid',
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEnhancedFilterSection(List<FoodStall> allShops) {
    final categories = allShops.map((stall) => stall.category).toSet().toList();
    categories.insert(0, 'All');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.subtleTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: AppTheme.textColor, size: 20),
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textColor),
                        items: categories.map((String category) {
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
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.subtleTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child:
                                _buildStatusToggle('All', Icons.all_inclusive),
                          ),
                          Expanded(
                            child:
                                _buildStatusToggle('Open', Icons.check_circle),
                          ),
                          Expanded(
                            child: _buildStatusToggle('Closed', Icons.cancel),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(String status, IconData icon) {
    bool isSelected = _selectedStatus == status;
    Color selectedColor = status == 'Open'
        ? Colors.green
        : status == 'Closed'
            ? Colors.red
            : AppTheme.primaryColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color:
              isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? selectedColor : AppTheme.subtleTextColor,
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? selectedColor : AppTheme.subtleTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.subtleTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No shops found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing your filter criteria',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.subtleTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
