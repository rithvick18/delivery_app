import 'package:flutter/material.dart';
import '../models/replacement_preference.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ReplacementPreferencesScreen extends StatelessWidget {
  final CartProvider provider;

  const ReplacementPreferencesScreen({
    super.key,
    required this.provider,
  });

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'eco':
        return Icons.eco_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'bakery_dining':
        return Icons.bakery_dining_rounded;
      case 'set_meal':
        return Icons.set_meal_rounded;
      default:
        return Icons.shopping_basket_rounded;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final preferences = provider.preferences;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solaris Gold Preferences',
              style: AppTypography.labelCaps.copyWith(color: AppColors.primary),
            ),
            Text(
              'Backup & Replacements',
              style: AppTypography.headlineMobile.copyWith(fontSize: 20),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Strategy Card Header
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.onSurface.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Global Default Strategy',
                                style: AppTypography.titleMd.copyWith(fontSize: 16),
                              ),
                              Text(
                                'How shoppers handle out-of-stock items',
                                style: AppTypography.bodySm.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Strategy Selector Chips
                    ...GlobalReplacementStrategy.values.map((strat) {
                      final isSelected = preferences.defaultStrategy == strat;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () => provider.updateGlobalStrategy(strat),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.surfaceContainerLow
                                  : AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryContainer
                                    : AppColors.outlineVariant,
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                                  color: isSelected ? AppColors.primary : AppColors.outline,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _getStrategyTitle(strat),
                                  style: AppTypography.bodyMd.copyWith(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Global Rules Switches
              Text(
                'Substitution Rules',
                style: AppTypography.titleMd,
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      activeThumbColor: AppColors.primaryContainer,
                      title: Text(
                        'Allow price increase up to 20%',
                        style: AppTypography.titleMd.copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Shopper can replace with premium brand if within price margin',
                        style: AppTypography.bodySm.copyWith(fontSize: 12),
                      ),
                      value: preferences.allowPriceIncreaseUpTo20Pct,
                      onChanged: (val) => provider.toggleAllowPriceIncrease(val),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    SwitchListTile(
                      activeThumbColor: AppColors.primaryContainer,
                      title: Text(
                        'Prefer organic for organic items',
                        style: AppTypography.titleMd.copyWith(fontSize: 14),
                      ),
                      subtitle: Text(
                        'Always look for organic alternatives when original item is organic',
                        style: AppTypography.bodySm.copyWith(fontSize: 12),
                      ),
                      value: preferences.preferOrganicIfOriginalOrganic,
                      onChanged: (val) => provider.togglePreferOrganic(val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Category Preferences Section
              Text(
                'Category Specific Rules',
                style: AppTypography.titleMd,
              ),
              const SizedBox(height: 10),

              ...preferences.categoryPreferences.map((cat) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getCategoryIcon(cat.iconName),
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.categoryName,
                              style: AppTypography.titleMd.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getStrategyTitle(cat.strategy),
                              style: AppTypography.labelCaps.copyWith(
                                fontSize: 11,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              cat.note,
                              style: AppTypography.bodySm.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.outline, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Edit rule for ${cat.categoryName}')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preferences saved successfully!'),
                        backgroundColor: AppColors.confidenceHigh,
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save Backup Preferences'),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
