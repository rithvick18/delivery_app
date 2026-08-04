import 'package:flutter/material.dart';
import '../models/live_order.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class LiveShopperCard extends StatelessWidget {
  final LiveOrderModel liveOrder;

  const LiveShopperCard({
    super.key,
    required this.liveOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with online status dot
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryContainer,
                    child: const Icon(Icons.person, color: AppColors.onPrimaryContainer),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.confidenceHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          liveOrder.shopperName,
                          style: AppTypography.titleMd.copyWith(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'LIVE SHOPPER',
                            style: AppTypography.labelCaps.copyWith(
                              fontSize: 9,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      liveOrder.shopperStatus,
                      style: AppTypography.bodySm.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Chat with ${liveOrder.shopperName}')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shopping Progress (${liveOrder.itemsCompleted} of ${liveOrder.totalItems} items)',
                style: AppTypography.labelCaps.copyWith(color: AppColors.onSurface),
              ),
              Text(
                '${(liveOrder.progressPercentage * 100).toInt()}%',
                style: AppTypography.labelCaps.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Linear Progress Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: LinearProgressIndicator(
              value: liveOrder.progressPercentage,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
