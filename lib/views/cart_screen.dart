import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final CartProvider provider;
  final AuthProvider? authProvider;

  const CartScreen({
    super.key,
    required this.provider,
    this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final cartItemsMap = provider.cartQuantities;
        final cartProducts = cartItemsMap.entries.map((entry) {
          final prod = ProductModel.sampleProducts.firstWhere(
            (p) => p.id == entry.key,
            orElse: () => ProductModel.sampleProducts.first,
          );
          return MapEntry(prod, entry.value);
        }).toList();

        final subtotal = provider.totalPrice;
        const deliveryFee = 3.99;
        final estimatedTax = subtotal * 0.08;
        final grandTotal = subtotal > 0 ? subtotal + deliveryFee + estimatedTax : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.selectedStore.name,
                  style: AppTypography.labelCaps.copyWith(color: AppColors.primary),
                ),
                Text(
                  'Your Shopping Cart',
                  style: AppTypography.headlineMobile.copyWith(fontSize: 20),
                ),
              ],
            ),
            actions: [
              if (cartProducts.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  tooltip: 'Clear Cart',
                  onPressed: () {
                    provider.clearCart();
                  },
                ),
            ],
          ),
          body: cartProducts.isEmpty
              ? _buildEmptyState(context)
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Store Fulfillment Banner
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.surfaceContainerHigh),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Fulfilling from ${provider.selectedStore.name} (${provider.selectedStore.deliveryTimeMins} mins)',
                                  style: AppTypography.bodySm.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Items (${provider.totalItemCount})',
                          style: AppTypography.titleMd,
                        ),
                        const SizedBox(height: 10),

                        // List of cart items
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartProducts.length,
                          separatorBuilder: (context, index) => const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final item = cartProducts[index];
                            final product = item.key;
                            final quantity = item.value;

                            return Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    product.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 60,
                                      height: 60,
                                      color: AppColors.surfaceContainerLow,
                                      child: const Icon(Icons.shopping_basket, color: AppColors.outline),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: AppTypography.titleMd.copyWith(fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Per ${product.unit}',
                                        style: AppTypography.bodySm.copyWith(fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: AppTypography.titleMd.copyWith(
                                          fontSize: 14,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 16),
                                        onPressed: () {
                                          provider.decrementQuantity(product.id);
                                        },
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        padding: EdgeInsets.zero,
                                      ),
                                      Text(
                                        '$quantity',
                                        style: AppTypography.titleMd.copyWith(fontSize: 14),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16),
                                        onPressed: () {
                                          provider.incrementQuantity(product.id);
                                        },
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Order Summary Card
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order Summary', style: AppTypography.titleMd),
                              const SizedBox(height: 12),
                              _buildCostRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                              const SizedBox(height: 6),
                              _buildCostRow('Delivery Fee', '\$${deliveryFee.toStringAsFixed(2)}'),
                              const SizedBox(height: 6),
                              _buildCostRow('Estimated Tax', '\$${estimatedTax.toStringAsFixed(2)}'),
                              const Divider(height: 20),
                              _buildCostRow('Total', '\$${grandTotal.toStringAsFixed(2)}', isBold: true),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
          bottomSheet: cartProducts.isEmpty
              ? null
              : Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final effectiveAuthProvider = authProvider ?? AuthProvider();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(
                                provider: provider,
                                authProvider: effectiveAuthProvider,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.onPrimaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text(
                          'Proceed to Checkout • \$${grandTotal.toStringAsFixed(2)}',
                          style: AppTypography.titleMd.copyWith(
                            fontSize: 16,
                            color: AppColors.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCostRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTypography.titleMd.copyWith(fontSize: 16)
              : AppTypography.bodySm.copyWith(fontSize: 14),
        ),
        Text(
          value,
          style: isBold
              ? AppTypography.titleMd.copyWith(fontSize: 16, color: AppColors.primary)
              : AppTypography.titleMd.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Cart is Empty',
              style: AppTypography.headlineMobile,
            ),
            const SizedBox(height: 8),
            Text(
              'Browse our stock-verified catalog to add fresh produce to your cart.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.onSurface,
                foregroundColor: Colors.white,
              ),
              child: const Text('Explore Produce Catalog'),
            ),
          ],
        ),
      ),
    );
  }
}
