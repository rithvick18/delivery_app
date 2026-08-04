enum ReplacementDecisionStatus { pending, approved, declined, customSelected }

/// Replacement recommendation option for out-of-stock items.
class ReplacementOption {
  final String id;
  final String title;
  final double price;
  final String unit;
  final int matchScore; // e.g. 95%
  final String imageUrl;
  final String reason;

  const ReplacementOption({
    required this.id,
    required this.title,
    required this.price,
    required this.unit,
    required this.matchScore,
    required this.imageUrl,
    required this.reason,
  });
}

/// Active item inside live shopping session.
class LiveOrderItem {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final String status; // 'In Cart', 'Searching', 'Out of Stock'
  final ReplacementOption? suggestedReplacement;

  const LiveOrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.status,
    this.suggestedReplacement,
  });
}

/// Live shopping session state & shopper info.
class LiveOrderModel {
  final String orderId;
  final String shopperName;
  final String shopperAvatarUrl;
  final String shopperStatus;
  final int totalItems;
  final int itemsCompleted;
  final String outOfStockItemName;
  final List<ReplacementOption> replacementOptions;
  final List<LiveOrderItem> items;

  const LiveOrderModel({
    required this.orderId,
    required this.shopperName,
    required this.shopperAvatarUrl,
    required this.shopperStatus,
    required this.totalItems,
    required this.itemsCompleted,
    required this.outOfStockItemName,
    required this.replacementOptions,
    required this.items,
  });

  double get progressPercentage => totalItems > 0 ? itemsCompleted / totalItems : 0.0;

  static LiveOrderModel get sampleLiveOrder => const LiveOrderModel(
        orderId: 'SOL-98421',
        shopperName: 'Marcus Vance',
        shopperAvatarUrl: 'assets/images/shopper_marcus.jpg',
        shopperStatus: 'Shopping in Dairy Aisle • Aisle 4',
        totalItems: 12,
        itemsCompleted: 8,
        outOfStockItemName: 'Organic Whole Milk 1 Gal',
        replacementOptions: [
          ReplacementOption(
            id: 'rep_1',
            title: 'Horizon Organic Whole Milk (1 Gal)',
            price: 5.99,
            unit: 'gal',
            matchScore: 95,
            imageUrl: 'assets/images/horizon_milk.jpg',
            reason: 'Same size, organic certified, brand match',
          ),
          ReplacementOption(
            id: 'rep_2',
            title: 'Organic Valley 2% Milk (1 Gal)',
            price: 5.49,
            unit: 'gal',
            matchScore: 82,
            imageUrl: 'assets/images/organic_valley.jpg',
            reason: 'Organic certified, lower fat content',
          ),
        ],
        items: [
          LiveOrderItem(id: 'i1', name: 'Organic Honeycrisp Apples', quantity: 2, unitPrice: 2.99, status: 'In Cart'),
          LiveOrderItem(id: 'i2', name: 'Hass Avocados', quantity: 4, unitPrice: 1.50, status: 'In Cart'),
          LiveOrderItem(id: 'i3', name: 'Organic Whole Milk 1 Gal', quantity: 1, unitPrice: 5.29, status: 'Out of Stock'),
          LiveOrderItem(id: 'i4', name: 'Artisanal Sourdough Bread', quantity: 1, unitPrice: 4.99, status: 'Searching'),
        ],
      );
}
