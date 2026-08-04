import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/active_order_banner.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

class ProductListingsScreen extends StatefulWidget {
  final CartProvider provider;
  final AuthProvider? authProvider;

  const ProductListingsScreen({
    super.key,
    required this.provider,
    this.authProvider,
  });

  @override
  State<ProductListingsScreen> createState() => _ProductListingsScreenState();
}

class _ProductListingsScreenState extends State<ProductListingsScreen> {
  String _selectedCategory = 'All Produce';
  String _searchQuery = '';

  final List<String> _categories = [
    'All Produce',
    'Organic',
    'Local Farms',
    'On Sale',
    'In Stock'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.provider.products.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.provider.fetchProductsForStore(widget.provider.selectedStore.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final selectedStore = widget.provider.selectedStore;
        final allProducts = widget.provider.products.isNotEmpty
            ? widget.provider.products
            : ProductModel.sampleProducts;

        final filteredProducts = allProducts.where((p) {
          final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
          if (!matchesSearch) return false;

          if (_selectedCategory == 'All Produce') return true;
          if (_selectedCategory == 'Organic') return p.isOrganic;
          if (_selectedCategory == 'Local Farms') return p.badgeText?.contains('Local') ?? false;
          if (_selectedCategory == 'On Sale') return p.badgeText != null;
          if (_selectedCategory == 'In Stock') return p.stockStatus != StockStatus.outOfStock;
          return true;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedStore.name,
                  style: AppTypography.labelCaps.copyWith(color: AppColors.primary),
                ),
                Text(
                  'Stock Confidence Produce',
                  style: AppTypography.headlineMobile.copyWith(fontSize: 20),
                ),
              ],
            ),
            actions: [
              ListenableBuilder(
                listenable: widget.provider,
                builder: (context, _) {
                  final count = widget.provider.totalItemCount;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.onSurface),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CartScreen(
                                provider: widget.provider,
                                authProvider: widget.authProvider,
                              ),
                            ),
                          );
                        },
                      ),
                      if (count > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            child: Text(
                              '$count',
                              textAlign: TextAlign.center,
                              style: AppTypography.badgeText.copyWith(
                                fontSize: 10,
                                color: AppColors.onPrimaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Order Banner (If order in progress)
                ActiveOrderBanner(provider: widget.provider),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: CustomSearchBar(
                    hintText: 'Search organic produce, local fruits...',
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),

                // Category Chips
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                          selectedColor: AppColors.primaryContainer,
                          backgroundColor: AppColors.surfaceContainerLowest,
                          labelStyle: AppTypography.bodySm.copyWith(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryContainer : AppColors.outlineVariant,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Product Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 80.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.63,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final qty = widget.provider.getQuantity(product.id);
                      return ProductCard(
                        product: product,
                        cartQuantity: qty,
                        onAdd: () {
                          widget.provider.incrementQuantity(product.id);
                        },
                        onRemove: () {
                          widget.provider.decrementQuantity(product.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomSheet: FloatingCartBar(
            provider: widget.provider,
            authProvider: widget.authProvider,
          ),
        );
      },
    );
  }
}
