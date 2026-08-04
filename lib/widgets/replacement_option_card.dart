import 'package:flutter/material.dart';
import '../models/live_order.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ReplacementOptionCard extends StatelessWidget {
  final ReplacementOption option;
  final bool isSelected;
  final VoidCallback onApprove;

  const ReplacementOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isSelected ? AppColors.primaryContainer : const Color(0xFFE2E8F0),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  width: 56,
                  height: 56,
                  color: AppColors.surfaceContainer,
                  child: Image.asset(
                    option.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primaryContainer.withValues(alpha: 0.15),
                      child: const Icon(Icons.local_grocery_store, color: AppColors.primary, size: 28),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: AppTypography.titleMd.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${option.price.toStringAsFixed(2)} / ${option.unit}',
                      style: AppTypography.titleMd.copyWith(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.reason,
                      style: AppTypography.bodySm.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.confidenceHigh.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${option.matchScore}% Match',
                  style: AppTypography.badgeText.copyWith(
                    color: AppColors.confidenceHigh,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: isSelected
                ? ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('Approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.confidenceHigh,
                      foregroundColor: Colors.white,
                    ),
                  )
                : OutlinedButton(
                    onPressed: onApprove,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
                    ),
                    child: Text(
                      'Approve This Swap',
                      style: AppTypography.titleMd.copyWith(
                        fontSize: 13,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
