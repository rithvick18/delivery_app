enum StockStatus { inStock, lowStock, outOfStock }

/// Model representing a grocery product with live stock confidence.
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String unit; // e.g., 'lb', 'bag', 'ea', 'gal'
  final int stockCount;
  final int stockConfidenceScore; // e.g. 95%
  final String category;
  final StockStatus stockStatus;
  final String imageUrl;
  final bool isOrganic;
  final String? badgeText; // e.g. 'Popular', 'Local', 'Limited'

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.stockCount,
    required this.stockConfidenceScore,
    required this.category,
    required this.stockStatus,
    required this.imageUrl,
    this.isOrganic = false,
    this.badgeText,
  });

  factory ProductModel.fromInventoryMap(Map<String, dynamic> map) {
    final productData = (map['products'] as Map<String, dynamic>?) ?? {};
    final String prodId = productData['id']?.toString() ?? map['product_id']?.toString() ?? map['id']?.toString() ?? '';
    final String name = productData['name']?.toString() ?? 'Product';
    final double price = (map['price'] as num?)?.toDouble() ?? 0.0;
    final String unit = productData['unit']?.toString() ?? 'ea';
    final int stockCount = (map['stock_count'] as num?)?.toInt() ?? 0;
    final int stockConfidenceScore = (map['stock_confidence'] as num?)?.toInt() ?? 90;
    final String category = productData['category']?.toString() ?? 'Produce';
    final String imageUrl = productData['image_url']?.toString() ?? '';
    final bool isOrganic = productData['is_organic'] == true;

    StockStatus status = StockStatus.inStock;
    if (stockCount == 0) {
      status = StockStatus.outOfStock;
    } else if (stockCount <= 10) {
      status = StockStatus.lowStock;
    }

    String? badge;
    if (stockCount == 0) {
      badge = 'Restocking Soon';
    } else if (stockCount <= 10) {
      badge = 'Low Stock';
    } else if (isOrganic) {
      badge = 'Organic';
    }

    return ProductModel(
      id: prodId,
      name: name,
      price: price,
      unit: unit,
      stockCount: stockCount,
      stockConfidenceScore: stockConfidenceScore,
      category: category,
      stockStatus: status,
      imageUrl: imageUrl,
      isOrganic: isOrganic,
      badgeText: badge,
    );
  }

  /// Sample mock produce items for Screen 2
  static List<ProductModel> get sampleProducts => const [
    ProductModel(
      id: 'prod_1',
      name: 'Organic Honeycrisp Apples',
      price: 2.99,
      unit: 'lb',
      stockCount: 42,
      stockConfidenceScore: 95,
      category: 'Produce',
      stockStatus: StockStatus.inStock,
      imageUrl:
          'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?w=400&h=400&fit=crop',
      isOrganic: true,
      badgeText: 'High Demand',
    ),
    ProductModel(
      id: 'prod_2',
      name: 'Hass Avocados',
      price: 1.50,
      unit: 'ea',
      stockCount: 5,
      stockConfidenceScore: 60,
      category: 'Produce',
      stockStatus: StockStatus.lowStock,
      imageUrl:
          'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=400&h=400&fit=crop',
      isOrganic: false,
      badgeText: 'Low Stock',
    ),
    ProductModel(
      id: 'prod_3',
      name: 'Organic Baby Spinach',
      price: 3.49,
      unit: 'bag (5 oz)',
      stockCount: 28,
      stockConfidenceScore: 99,
      category: 'Produce',
      stockStatus: StockStatus.inStock,
      imageUrl:
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&h=400&fit=crop',
      isOrganic: true,
      badgeText: 'Organic',
    ),
    ProductModel(
      id: 'prod_4',
      name: 'Heirloom Tomatoes',
      price: 4.25,
      unit: 'lb',
      stockCount: 0,
      stockConfidenceScore: 20,
      category: 'Produce',
      stockStatus: StockStatus.outOfStock,
      imageUrl:
          'https://images.unsplash.com/photo-1592841200221-21e1c0d36875?w=400&h=400&fit=crop',
      isOrganic: true,
      badgeText: 'Restocking 2 PM',
    ),
    ProductModel(
      id: 'prod_5',
      name: 'Fresh Organic Bananas',
      price: 0.79,
      unit: 'lb',
      stockCount: 65,
      stockConfidenceScore: 98,
      category: 'Produce',
      stockStatus: StockStatus.inStock,
      imageUrl:
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
      isOrganic: true,
    ),
    ProductModel(
      id: 'prod_6',
      name: 'Sweet Yellow Strawberries',
      price: 4.99,
      unit: 'pack (16 oz)',
      stockCount: 12,
      stockConfidenceScore: 84,
      category: 'Produce',
      stockStatus: StockStatus.inStock,
      imageUrl:
          'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400&h=400&fit=crop',
      isOrganic: false,
      badgeText: 'Local Farm',
    ),
  ];
}
