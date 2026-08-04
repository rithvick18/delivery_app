import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class StockConfidenceBadge extends StatelessWidget {
  final int scorePercentage;
  final bool showLabel;

  const StockConfidenceBadge({
    super.key,
    required this.scorePercentage,
    this.showLabel = true,
  });

  Color get _badgeColor {
    if (scorePercentage >= 90) return AppColors.confidenceHigh;
    if (scorePercentage >= 70) return AppColors.confidenceMedium;
    return AppColors.confidenceLow;
  }

  String get _levelText {
    if (scorePercentage >= 90) return 'High';
    if (scorePercentage >= 70) return 'Med';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            showLabel ? '$scorePercentage% Confidence ($_levelText)' : '$scorePercentage%',
            style: AppTypography.badgeText.copyWith(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
