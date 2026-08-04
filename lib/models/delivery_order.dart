enum DeliveryOrderStatus {
  available,
  accepted,
  arrivedAtStore,
  pickingItems,
  inTransit,
  arrivedAtCustomer,
  completed,
  cancelled,
}

enum DeliveryItemStatus {
  pending,
  picked,
  outOfStock,
  substituted,
}

class DeliveryOrderItem {
  final String id;
  final String name;
  final String category;
  final String aisleLocation;
  final double unitPrice;
  final int requestedQuantity;
  int pickedQuantity;
  DeliveryItemStatus status;
  final String? imageUrl;
  String? substituteItemName;
  String? substituteNote;

  DeliveryOrderItem({
    required this.id,
    required this.name,
    required this.category,
    required this.aisleLocation,
    required this.unitPrice,
    required this.requestedQuantity,
    this.pickedQuantity = 0,
    this.status = DeliveryItemStatus.pending,
    this.imageUrl,
    this.substituteItemName,
    this.substituteNote,
  });

  double get totalPrice => unitPrice * requestedQuantity;

  factory DeliveryOrderItem.fromMap(Map<String, dynamic> map) {
    return DeliveryOrderItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Grocery Item',
      category: map['category']?.toString() ?? 'General',
      aisleLocation: map['aisle_location']?.toString() ?? 'Aisle 1',
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 3.99,
      requestedQuantity: (map['requested_quantity'] as num?)?.toInt() ?? 1,
      pickedQuantity: (map['picked_quantity'] as num?)?.toInt() ?? 0,
      status: DeliveryItemStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'pending'),
        orElse: () => DeliveryItemStatus.pending,
      ),
      imageUrl: map['image_url']?.toString(),
      substituteItemName: map['substitute_item_name']?.toString(),
      substituteNote: map['substitute_note']?.toString(),
    );
  }
}

class DeliveryOrderModel {
  final String id;
  final String orderNumber;
  final String storeId;
  final String storeName;
  final String storeAddress;
  final String storeImageUrl;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String? deliveryInstructions;

  final double basePayout;
  final double tipAmount;
  final double bonusPay;
  final double estimatedDistanceMiles;
  final int estimatedDurationMins;
  final DateTime expectedDeliveryTime;

  final List<DeliveryOrderItem> items;
  DeliveryOrderStatus status;
  DateTime? acceptedAt;
  DateTime? completedAt;
  String? proofOfDeliveryNote;

  DeliveryOrderModel({
    required this.id,
    required this.orderNumber,
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.storeImageUrl,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    this.deliveryInstructions,
    required this.basePayout,
    required this.tipAmount,
    this.bonusPay = 0.0,
    required this.estimatedDistanceMiles,
    required this.estimatedDurationMins,
    required this.expectedDeliveryTime,
    required this.items,
    this.status = DeliveryOrderStatus.available,
    this.acceptedAt,
    this.completedAt,
    this.proofOfDeliveryNote,
  });

  double get totalPayout => basePayout + tipAmount + bonusPay;

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.requestedQuantity);
  int get pickedItemCount => items.fold(0, (sum, item) => sum + (item.status == DeliveryItemStatus.picked ? item.pickedQuantity : 0));

  bool get isPickingComplete => items.every((item) => item.status != DeliveryItemStatus.pending);

  static List<DeliveryOrderModel> get sampleOrders => [
    DeliveryOrderModel(
      id: 'order_101',
      orderNumber: '#SOL-8921',
      storeId: 'store_1',
      storeName: 'Solaris Supercenter',
      storeAddress: '742 Evergreen Terrace, Springfield',
      storeImageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400&h=400&fit=crop',
      customerName: 'Eleanor Vance',
      customerAddress: '104 West End Ave, Springfield, Apt 4B',
      customerPhone: '+1 (555) 019-2834',
      deliveryInstructions: 'Leave on porch. Ring bell once. Gate code: #4920',
      basePayout: 14.50,
      tipAmount: 6.00,
      bonusPay: 2.50,
      estimatedDistanceMiles: 3.2,
      estimatedDurationMins: 25,
      expectedDeliveryTime: DateTime.now().add(const Duration(minutes: 35)),
      items: [
        DeliveryOrderItem(
          id: 'item_1',
          name: 'Organic Hass Avocados (4 Pack)',
          category: 'Produce',
          aisleLocation: 'Aisle 1 - Produce Bay A',
          unitPrice: 4.99,
          requestedQuantity: 2,
          imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=300&fit=crop',
        ),
        DeliveryOrderItem(
          id: 'item_2',
          name: 'Whole Organic Milk 1 Gal',
          category: 'Dairy',
          aisleLocation: 'Aisle 4 - Fridge 12',
          unitPrice: 5.49,
          requestedQuantity: 1,
          imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=300&fit=crop',
        ),
        DeliveryOrderItem(
          id: 'item_3',
          name: 'Artisanal Sourdough Bread',
          category: 'Bakery',
          aisleLocation: 'Aisle 2 - Bakery Shelf',
          unitPrice: 6.29,
          requestedQuantity: 1,
          imageUrl: 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=300&fit=crop',
        ),
        DeliveryOrderItem(
          id: 'item_4',
          name: 'Fresh Strawberries 16oz',
          category: 'Produce',
          aisleLocation: 'Aisle 1 - Produce Cooler',
          unitPrice: 3.99,
          requestedQuantity: 2,
          imageUrl: 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=300&fit=crop',
        ),
      ],
    ),
    DeliveryOrderModel(
      id: 'order_102',
      orderNumber: '#SOL-8924',
      storeId: 'store_2',
      storeName: 'Solaris Market & Bakery',
      storeAddress: '120 Oakridge Blvd, Springfield',
      storeImageUrl: 'https://images.unsplash.com/photo-1517523791225-289075439574?w=400&h=400&fit=crop',
      customerName: 'Marcus Brodie',
      customerAddress: '88 High Street, Springfield',
      customerPhone: '+1 (555) 014-9981',
      deliveryInstructions: 'Hand to me. Beware of friendly dog in garden.',
      basePayout: 18.00,
      tipAmount: 8.50,
      bonusPay: 0.0,
      estimatedDistanceMiles: 4.8,
      estimatedDurationMins: 35,
      expectedDeliveryTime: DateTime.now().add(const Duration(minutes: 50)),
      items: [
        DeliveryOrderItem(
          id: 'item_5',
          name: 'Cold Brew Coffee Concentrate 32oz',
          category: 'Beverages',
          aisleLocation: 'Aisle 3 - Coffee & Tea',
          unitPrice: 8.99,
          requestedQuantity: 1,
          imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=300&fit=crop',
        ),
        DeliveryOrderItem(
          id: 'item_6',
          name: 'Greek Yogurt Vanilla 32oz',
          category: 'Dairy',
          aisleLocation: 'Aisle 4 - Dairy Cooler',
          unitPrice: 4.79,
          requestedQuantity: 2,
          imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=300&fit=crop',
        ),
        DeliveryOrderItem(
          id: 'item_7',
          name: 'Organic Honey Granola',
          category: 'Breakfast',
          aisleLocation: 'Aisle 5 - Cereal',
          unitPrice: 5.99,
          requestedQuantity: 1,
          imageUrl: 'https://images.unsplash.com/photo-1517093728432-a0440f8d4514?w=300&fit=crop',
        ),
      ],
    ),
    DeliveryOrderModel(
      id: 'order_103',
      orderNumber: '#SOL-8930',
      storeId: 'store_3',
      storeName: 'Solaris Organic Express',
      storeAddress: '405 Pine Street, Springfield',
      storeImageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&h=400&fit=crop',
      customerName: 'Sophia Loren',
      customerAddress: '512 Riverbed Way, Springfield',
      customerPhone: '+1 (555) 018-7722',
      deliveryInstructions: 'Concierge desk will grant elevator access.',
      basePayout: 11.20,
      tipAmount: 4.50,
      bonusPay: 1.50,
      estimatedDistanceMiles: 2.1,
      estimatedDurationMins: 20,
      expectedDeliveryTime: DateTime.now().add(const Duration(minutes: 30)),
      items: [
        DeliveryOrderItem(
          id: 'item_8',
          name: 'Sparkling Mineral Water 6-Pack',
          category: 'Beverages',
          aisleLocation: 'Aisle 3 - Water Bay',
          unitPrice: 6.99,
          requestedQuantity: 2,
          imageUrl: 'https://images.unsplash.com/photo-1527960471264-932f39eb5846?w=300&fit=crop',
        ),
        DeliveryOrderItem(
          id: 'item_9',
          name: 'Organic Baby Spinach 8oz',
          category: 'Produce',
          aisleLocation: 'Aisle 1 - Salad Greens',
          unitPrice: 3.49,
          requestedQuantity: 1,
          imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=300&fit=crop',
        ),
      ],
    ),
  ];
}
