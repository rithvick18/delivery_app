import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../views/cart_screen.dart';

class FloatingCartBar extends StatelessWidget {
  final CartProvider provider;
  final AuthProvider? authProvider;

  const FloatingCartBar({
    super.key,
    required this.provider,
    this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.totalItemCount == 0) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          color: AppColors.onSurface,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartScreen(
                    provider: provider,
                    authProvider: authProvider,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${provider.totalItemCount}',
                      style: AppTypography.badgeText.copyWith(
                        color: AppColors.onPrimaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Cart',
                        style: AppTypography.titleMd.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Total: \$${provider.totalPrice.toStringAsFixed(2)}',
                        style: AppTypography.bodySm.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        'Checkout',
                        style: AppTypography.titleMd.copyWith(
                          color: AppColors.primaryContainer,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primaryContainer,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
