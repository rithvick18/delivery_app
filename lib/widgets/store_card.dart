import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/store.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'stock_confidence_badge.dart';

class StoreImage extends StatelessWidget {
  final String imageUrl;

  const StoreImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.primaryContainer.withValues(alpha: 0.15),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.primary,
            size: 36,
          ),
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.primaryContainer.withValues(alpha: 0.15),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.primary,
            size: 36,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.primaryContainer.withValues(alpha: 0.15),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.primary,
            size: 36,
          ),
        ),
      );
    }
  }
}

class StoreCard extends StatelessWidget {
  final StoreModel store;
  final bool isSelected;
  final VoidCallback onTap;

  const StoreCard({
    super.key,
    required this.store,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.surfaceContainerLow
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryContainer
              : const Color(0xFFE2E8F0),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primaryContainer.withValues(alpha: 0.12)
                : AppColors.onSurface.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Image Thumbnail with Fallback
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: AppColors.surfaceContainer,
                    child: StoreImage(imageUrl: store.imageUrl),
                  ),
                ),
                const SizedBox(width: 14),
                // Store Information Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store.name,
                              style: AppTypography.titleMd.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Selected',
                                style: AppTypography.badgeText.copyWith(
                                  color: AppColors.onPrimaryContainer,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${store.distanceMiles} mi • ${store.address}',
                        style: AppTypography.bodySm.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: AppColors.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${store.deliveryTimeMins} min delivery (${store.pickupTimeMins} min pickup)',
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          StockConfidenceBadge(
                            scorePercentage: store.stockConfidenceScore,
                          ),
                          ...store.tags
                              .take(2)
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tag,
                                    style: AppTypography.labelCaps.copyWith(
                                      fontSize: 10,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
