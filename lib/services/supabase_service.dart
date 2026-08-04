import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../models/delivery_order.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://idiqnfrpbslnagkmuvck.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlkaXFuZnJwYnNsbmFna211dmNrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NTc0NTg3MCwiZXhwIjoyMTAxMzIxODcwfQ.SoL82AINtVf6LTGLS4VvOlXg0i1upjWb5bjversndk8';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: supabaseAnonKey,
    );
  }

  SupabaseClient get client => Supabase.instance.client;

  Future<List<StoreModel>> fetchStores() async {
    try {
      final response = await client
          .from('stores')
          .select('*')
          .order('name', ascending: true);

      final list = (response as List).cast<Map<String, dynamic>>();
      // Print exact response length as requested
      debugPrint(
        '[SupabaseService.fetchStores] Response length: ${list.length}',
      );
      if (list.isEmpty) {
        debugPrint(
          '[SupabaseService.fetchStores] Warning: Supabase returned 0 stores.',
        );
      }
      return list.map((map) => StoreModel.fromMap(map)).toList();
    } catch (e, stack) {
      // Print exact error message as requested
      debugPrint('[SupabaseService.fetchStores] Error fetching stores: $e');
      debugPrint(stack.toString());
      return [];
    }
  }

  Future<List<ProductModel>> fetchStoreInventory(String storeId) async {
    final isUuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(storeId);
    if (!isUuid) {
      debugPrint(
        '[SupabaseService.fetchStoreInventory] Non-UUID store_id: "$storeId" passed. Skipping Supabase query.',
      );
      return [];
    }

    try {
      final response = await client
          .from('store_inventory')
          .select('*, products(*)')
          .eq('store_id', storeId);

      final list = (response as List).cast<Map<String, dynamic>>();
      // Print exact response length as requested
      debugPrint(
        '[SupabaseService.fetchStoreInventory] store_id: $storeId | Response length: ${list.length}',
      );
      if (list.isEmpty) {
        debugPrint(
          '[SupabaseService.fetchStoreInventory] Warning: Supabase returned 0 inventory items for store_id: $storeId.',
        );
      }
      return list.map((map) => ProductModel.fromInventoryMap(map)).toList();
    } catch (e, stack) {
      // Print exact error message as requested
      debugPrint(
        '[SupabaseService.fetchStoreInventory] Error fetching inventory for store_id $storeId: $e',
      );
      debugPrint(stack.toString());
      return [];
    }
  }

  Future<List<ProductModel>> fetchProductsForStore(String storeId) async {
    return fetchStoreInventory(storeId);
  }

  // Driver Profile Methods
  Future<Map<String, dynamic>?> fetchDriverProfile(String driverId) async {
    try {
      final response = await client
          .from('profiles')
          .select('*')
          .eq('id', driverId)
          .maybeSingle();

      return response;
    } catch (e, stack) {
      debugPrint(
        '[SupabaseService.fetchDriverProfile] Error fetching driver profile: $e',
      );
      debugPrint(stack.toString());
      return null;
    }
  }

  Future<bool> updateDriverProfile(Map<String, dynamic> profileData) async {
    try {
      await client.from('profiles').upsert(profileData);
      return true;
    } catch (e, stack) {
      debugPrint(
        '[SupabaseService.updateDriverProfile] Error updating driver profile: $e',
      );
      debugPrint(stack.toString());
      return false;
    }
  }

  Future<bool> updateDriverOnlineStatus(String driverId, bool isOnline) async {
    try {
      await client
          .from('profiles')
          .update({
            'is_online': isOnline,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', driverId);
      return true;
    } catch (e, stack) {
      debugPrint(
        '[SupabaseService.updateDriverOnlineStatus] Error updating online status: $e',
      );
      debugPrint(stack.toString());
      return false;
    }
  }

  // Order Methods
  Future<List<DeliveryOrderModel>> fetchAvailableOrders() async {
    try {
      final response = await client
          .from('orders')
          .select('*')
          .eq('status', 'pending')
          .order('created_at', ascending: true);

      final list = (response as List).cast<Map<String, dynamic>>();
      return list.map((map) => DeliveryOrderModel.fromMap(map)).toList();
    } catch (e, stack) {
      debugPrint(
        '[SupabaseService.fetchAvailableOrders] Error fetching available orders: $e',
      );
      debugPrint(stack.toString());
      return [];
    }
  }

  Future<DeliveryOrderModel?> fetchOrderById(String orderId) async {
    try {
      final response = await client
          .from('orders')
          .select('*')
          .eq('id', orderId)
          .maybeSingle();

      if (response != null) {
        return DeliveryOrderModel.fromMap(response);
      }
      return null;
    } catch (e, stack) {
      debugPrint('[SupabaseService.fetchOrderById] Error fetching order: $e');
      debugPrint(stack.toString());
      return null;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await client
          .from('orders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
      return true;
    } catch (e, stack) {
      debugPrint(
        '[SupabaseService.updateOrderStatus] Error updating order status: $e',
      );
      debugPrint(stack.toString());
      return false;
    }
  }

  Future<bool> updateOrderItemStatus(
    String orderId,
    String itemId,
    String status, {
    int? pickedQuantity,
    String? substituteItemName,
    String? substituteNote,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (pickedQuantity != null) {
        updateData['picked_quantity'] = pickedQuantity.toString();
      }
      if (substituteItemName != null) {
        updateData['substitute_item_name'] = substituteItemName;
      }
      if (substituteNote != null) {
        updateData['substitute_note'] = substituteNote;
      }

      await client
          .from('order_items')
          .update(updateData)
          .eq('order_id', orderId)
          .eq('id', itemId);

      return true;
    } catch (e, stack) {
      debugPrint(
        '[SupabaseService.updateOrderItemStatus] Error updating order item status: $e',
      );
      debugPrint(stack.toString());
      return false;
    }
  }

  Future<bool> completeOrder(String orderId, String proofOfDeliveryNote) async {
    try {
      await client
          .from('orders')
          .update({
            'status': 'delivered',
            'proof_of_delivery_note': proofOfDeliveryNote,
            'completed_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
      return true;
    } catch (e, stack) {
      debugPrint('[SupabaseService.completeOrder] Error completing order: $e');
      debugPrint(stack.toString());
      return false;
    }
  }

  // Realtime subscription methods
  Stream<List<Map<String, dynamic>>> streamAvailableOrders() {
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .order('created_at', ascending: true)
        .map((event) => (event as List).cast<Map<String, dynamic>>());
  }

  Stream<Map<String, dynamic>> streamOrderById(String orderId) {
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((event) => (event as List).first);
  }
}
