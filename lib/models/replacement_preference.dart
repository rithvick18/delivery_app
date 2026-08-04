enum GlobalReplacementStrategy {
  bestMatch,
  sameBrandOnly,
  contactFirst,
  dontReplace,
}

class CategoryPreference {
  final String categoryName;
  final String iconName;
  final GlobalReplacementStrategy strategy;
  final String note;

  const CategoryPreference({
    required this.categoryName,
    required this.iconName,
    required this.strategy,
    required this.note,
  });
}

class ReplacementPreferenceModel {
  final GlobalReplacementStrategy defaultStrategy;
  final bool allowPriceIncreaseUpTo20Pct;
  final bool preferOrganicIfOriginalOrganic;
  final List<CategoryPreference> categoryPreferences;

  const ReplacementPreferenceModel({
    required this.defaultStrategy,
    required this.allowPriceIncreaseUpTo20Pct,
    required this.preferOrganicIfOriginalOrganic,
    required this.categoryPreferences,
  });

  static ReplacementPreferenceModel get samplePreferences => const ReplacementPreferenceModel(
        defaultStrategy: GlobalReplacementStrategy.bestMatch,
        allowPriceIncreaseUpTo20Pct: true,
        preferOrganicIfOriginalOrganic: true,
        categoryPreferences: [
          CategoryPreference(
            categoryName: 'Fresh Produce',
            iconName: 'eco',
            strategy: GlobalReplacementStrategy.bestMatch,
            note: 'Prefer local farms & organic variants',
          ),
          CategoryPreference(
            categoryName: 'Dairy & Milk',
            iconName: 'water_drop',
            strategy: GlobalReplacementStrategy.sameBrandOnly,
            note: 'Strict brand match for lactose-free milk',
          ),
          CategoryPreference(
            categoryName: 'Bakery & Bread',
            iconName: 'bakery_dining',
            strategy: GlobalReplacementStrategy.contactFirst,
            note: 'Call before swapping artisanal sourdough',
          ),
          CategoryPreference(
            categoryName: 'Meat & Seafood',
            iconName: 'set_meal',
            strategy: GlobalReplacementStrategy.dontReplace,
            note: 'Do not substitute wild salmon',
          ),
        ],
      );
}
