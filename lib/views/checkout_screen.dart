import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/replacement_preference.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'live_shopping_screen.dart';
import 'replacement_preferences_screen.dart';
import 'login_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final CartProvider provider;
  final AuthProvider authProvider;

  const CheckoutScreen({
    super.key,
    required this.provider,
    required this.authProvider,
  });

  String _getStrategyTitle(GlobalReplacementStrategy strategy) {
    switch (strategy) {
      case GlobalReplacementStrategy.bestMatch:
        return 'Best Match (AI Recommended)';
      case GlobalReplacementStrategy.sameBrandOnly:
        return 'Specific Brand Only';
      case GlobalReplacementStrategy.contactFirst:
        return 'Contact Me First';
      case GlobalReplacementStrategy.dontReplace:
        return 'Don\'t Replace (Refund)';
    }
  }

  void _onPlaceOrder(BuildContext context) {
    final user = authProvider.user;
    if (user == null) {
      // Guard flow: Prompt Google Sign-In if unauthenticated
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in with Google to place and link your order.'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            authProvider: authProvider,
            onSuccess: () {
              Navigator.pop(context);
              _executeOrderPlacement(context);
            },
          ),
        ),
      );
      return;
    }

    _executeOrderPlacement(context);
  }

  void _executeOrderPlacement(BuildContext context) {
    final currentUser = authProvider.user;
    final userId = currentUser?.id;

    provider.placeOrder();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order Placed! Linked to Supabase User ID: ${userId != null ? "${userId.substring(0, 8)}..." : "Guest"}',
        ),
        backgroundColor: AppColors.confidenceHigh,
        duration: const Duration(seconds: 4),
      ),
    );

    // Push LiveShoppingScreen and clear checkout stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LiveShoppingScreen(provider: provider),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([provider, authProvider]),
      builder: (context, _) {
        final preferences = provider.preferences;
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
        final grandTotal = subtotal + deliveryFee + estimatedTax;

        final currentUser = authProvider.user;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Checkout Review',
              style: AppTypography.headlineMobile,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Auth Status Notice if guest
                  if (currentUser == null) ...[
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryContainer),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sign in to link orders and delivery addresses directly to your Supabase profile.',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurface,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(authProvider: authProvider),
                                ),
                              );
                            },
                            child: Text(
                              'Sign In',
                              style: AppTypography.labelCaps.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Delivery Destination Card
                  Text('Delivery Destination', style: AppTypography.titleMd),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('742 Evergreen Terrace', style: AppTypography.titleMd.copyWith(fontSize: 15)),
                              Text(
                                currentUser != null
                                    ? 'Springfield, OR • Linked to User ID ${currentUser.id.substring(0, 8)}...'
                                    : 'Springfield, OR • Sign in to save address',
                                style: AppTypography.bodySm.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('Edit', style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Integrated Backup & Replacement Preferences Step
                  Text('Backup & Replacement Preferences', style: AppTypography.titleMd),
                  const SizedBox(height: 4),
                  Text(
                    'Configure how your shopper handles out-of-stock items',
                    style: AppTypography.bodySm.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.8), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getStrategyTitle(preferences.defaultStrategy),
                                style: AppTypography.titleMd.copyWith(fontSize: 15, color: AppColors.primary),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReplacementPreferencesScreen(provider: provider),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: const Size(0, 32),
                                side: const BorderSide(color: AppColors.primary),
                              ),
                              icon: const Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
                              label: Text(
                                'Change',
                                style: AppTypography.bodySm.copyWith(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (preferences.allowPriceIncreaseUpTo20Pct)
                              Chip(
                                label: const Text('Price +20% OK'),
                                labelStyle: AppTypography.labelCaps.copyWith(fontSize: 10),
                                backgroundColor: AppColors.surfaceContainerLow,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            if (preferences.preferOrganicIfOriginalOrganic)
                              Chip(
                                label: const Text('Prefer Organic'),
                                labelStyle: AppTypography.labelCaps.copyWith(fontSize: 10),
                                backgroundColor: AppColors.surfaceContainerLow,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment Method Selection
                  Text('Payment Method', style: AppTypography.titleMd),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.credit_card_rounded, color: AppColors.onSurface, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Apple Pay •••• 4920', style: AppTypography.titleMd.copyWith(fontSize: 15)),
                              Text('Solaris Gold Rewards Applied', style: AppTypography.bodySm.copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_rounded, color: AppColors.confidenceHigh, size: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Items Summary Card
                  Text('Order Items (${provider.totalItemCount})', style: AppTypography.titleMd),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: cartProducts.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${entry.value}x ${entry.key.name}',
                                  style: AppTypography.bodySm.copyWith(fontSize: 14, color: AppColors.onSurface),
                                ),
                              ),
                              Text(
                                '\$${(entry.key.price * entry.value).toStringAsFixed(2)}',
                                style: AppTypography.titleMd.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Price Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildRow('Item Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        _buildRow('Delivery Fee', '\$${deliveryFee.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        _buildRow('Tax & Fees', '\$${estimatedTax.toStringAsFixed(2)}'),
                        const Divider(height: 16),
                        _buildRow('Total Due', '\$${grandTotal.toStringAsFixed(2)}', isBold: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _onPlaceOrder(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.confidenceHigh,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Place Order • \$${grandTotal.toStringAsFixed(2)}',
                    style: AppTypography.titleMd.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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

  Widget _buildRow(String label, String value, {bool isBold = false}) {
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
}
