/// Model representing a grocery store in Solaris Gold.
class StoreModel {
  final String id;
  final String name;
  final String address;
  final double distanceMiles;
  final int pickupTimeMins;
  final int deliveryTimeMins;
  final int stockConfidenceScore; // e.g. 98%
  final String imageUrl;
  final bool isPrimary;
  final bool isOpen;
  final List<String>
  tags; // e.g., ['Organic', 'Live Stock Tracking', 'Pickup Available']

  const StoreModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceMiles,
    required this.pickupTimeMins,
    required this.deliveryTimeMins,
    required this.stockConfidenceScore,
    required this.imageUrl,
    this.isPrimary = false,
    this.isOpen = true,
    required this.tags,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    double distance = 1.0;
    if (map['distance'] != null) {
      distance = double.tryParse(map['distance'].toString()) ?? 1.0;
    } else if (map['distance_miles'] != null) {
      distance = double.tryParse(map['distance_miles'].toString()) ?? 1.0;
    }

    int deliveryTime = 30;
    final delTimeStr = map['delivery_time']?.toString() ?? '';
    final match = RegExp(r'\d+').firstMatch(delTimeStr);
    if (match != null) {
      deliveryTime = int.tryParse(match.group(0)!) ?? 30;
    } else if (map['delivery_time_mins'] != null) {
      deliveryTime = (map['delivery_time_mins'] as num).toInt();
    }

    List<String> parsedTags = ['Open Now', 'Live Stock Sync', '30 Min Delivery'];
    if (map['tags'] != null && map['tags'] is List) {
      parsedTags = (map['tags'] as List).map((t) => t.toString()).toList();
    }

    return StoreModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Solaris Store',
      address: map['address']?.toString() ?? 'Springfield',
      distanceMiles: distance,
      pickupTimeMins: (map['pickup_time_mins'] as num?)?.toInt() ?? 15,
      deliveryTimeMins: deliveryTime,
      stockConfidenceScore: (map['stock_confidence_score'] as num?)?.toInt() ?? 95,
      imageUrl: map['image_url']?.toString() ?? 'assets/images/stores/store_1.jpg',
      isPrimary: map['is_primary'] == true,
      isOpen: map['is_open'] ?? true,
      tags: parsedTags,
    );
  }

  /// Sample mock stores for the app
  static List<StoreModel> get sampleStores => const [
    StoreModel(
      id: 'store_1',
      name: 'Solaris Supercenter',
      address: '742 Evergreen Terrace, Springfield',
      distanceMiles: 0.8,
      pickupTimeMins: 15,
      deliveryTimeMins: 30,
      stockConfidenceScore: 98,
      imageUrl:
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400&h=400&fit=crop',
      isPrimary: true,
      isOpen: true,
      tags: [
        'Open Now',
        'Live Stock Sync',
        '30 Min Delivery',
        'Curbside Pickup',
      ],
    ),
    StoreModel(
      id: 'store_2',
      name: 'Solaris Market & Bakery',
      address: '120 Oakridge Blvd, Springfield',
      distanceMiles: 1.5,
      pickupTimeMins: 20,
      deliveryTimeMins: 45,
      stockConfidenceScore: 92,
      imageUrl:
          'https://images.unsplash.com/photo-1517523791225-289075439574?w=400&h=400&fit=crop',
      isPrimary: false,
      isOpen: true,
      tags: ['Open Now', 'Artisanal Bakery', 'Local Produce'],
    ),
    StoreModel(
      id: 'store_3',
      name: 'Solaris Organic Express',
      address: '405 Pine Street, Springfield',
      distanceMiles: 2.3,
      pickupTimeMins: 25,
      deliveryTimeMins: 50,
      stockConfidenceScore: 89,
      imageUrl:
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&h=400&fit=crop',
      isPrimary: false,
      isOpen: true,
      tags: ['100% Organic', 'Farm Direct', 'Live Stock Tracking'],
    ),
  ];
}
