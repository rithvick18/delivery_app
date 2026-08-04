import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'stock_confidence_badge.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;

  const ProductImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.primaryContainer.withValues(alpha: 0.12),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.primary,
            size: 48,
          ),
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.primaryContainer.withValues(alpha: 0.12),
          child: const Icon(Icons.image, color: AppColors.primary, size: 48),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.primaryContainer.withValues(alpha: 0.12),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.primary,
            size: 48,
          ),
        ),
      );
    }
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final int cartQuantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductCard({
    super.key,
    required this.product,
    required this.cartQuantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stockStatus == StockStatus.outOfStock;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container with Badge Overlay & Image Error Fallback
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16.0),
                ),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: AppColors.surfaceContainer,
                  child: ProductImage(imageUrl: product.imageUrl),
                ),
              ),
              if (product.badgeText != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? AppColors.errorContainer
                          : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.badgeText!,
                      style: AppTypography.badgeText.copyWith(
                        color: isOutOfStock
                            ? AppColors.onErrorContainer
                            : AppColors.onPrimaryContainer,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: StockConfidenceBadge(
                  scorePercentage: product.stockConfidenceScore,
                  showLabel: false,
                ),
              ),
            ],
          ),

          // Details Padding
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTypography.titleMd.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: AppTypography.titleMd.copyWith(
                        fontSize: 15,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      ' / ${product.unit}',
                      style: AppTypography.bodySm.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Stock Info Text
                Text(
                  isOutOfStock
                      ? 'Out of Stock'
                      : '${product.stockCount} left • ${product.stockConfidenceScore}% confidence',
                  style: AppTypography.labelCaps.copyWith(
                    fontSize: 10,
                    color: isOutOfStock ? AppColors.error : AppColors.outline,
                  ),
                ),

                const SizedBox(height: 10),

                // Quantity / Add to Cart Controller
                isOutOfStock
                    ? SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: const BorderSide(
                              color: AppColors.outlineVariant,
                            ),
                          ),
                          child: Text(
                            'Unavailable',
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.outline,
                            ),
                          ),
                        ),
                      )
                    : cartQuantity == 0
                    ? SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: onAdd,
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            textStyle: AppTypography.titleMd.copyWith(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primaryContainer),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              onPressed: onRemove,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 36,
                              ),
                            ),
                            Text(
                              '$cartQuantity',
                              style: AppTypography.titleMd.copyWith(
                                fontSize: 14,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              onPressed: onAdd,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 36,
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
