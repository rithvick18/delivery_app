import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/store.dart';
import '../models/product.dart';

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
      print('[SupabaseService.fetchStores] Response length: ${list.length}');
      if (list.isEmpty) {
        print('[SupabaseService.fetchStores] Warning: Supabase returned 0 stores.');
      }
      return list.map((map) => StoreModel.fromMap(map)).toList();
    } catch (e, stack) {
      // Print exact error message as requested
      print('[SupabaseService.fetchStores] Error fetching stores: $e');
      print(stack);
      return [];
    }
  }

  Future<List<ProductModel>> fetchStoreInventory(String storeId) async {
    final isUuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(storeId);
    if (!isUuid) {
      print('[SupabaseService.fetchStoreInventory] Non-UUID store_id: "$storeId" passed. Skipping Supabase query.');
      return [];
    }

    try {
      final response = await client
          .from('store_inventory')
          .select('*, products(*)')
          .eq('store_id', storeId);

      final list = (response as List).cast<Map<String, dynamic>>();
      // Print exact response length as requested
      print('[SupabaseService.fetchStoreInventory] store_id: $storeId | Response length: ${list.length}');
      if (list.isEmpty) {
        print('[SupabaseService.fetchStoreInventory] Warning: Supabase returned 0 inventory items for store_id: $storeId.');
      }
      return list.map((map) => ProductModel.fromInventoryMap(map)).toList();
    } catch (e, stack) {
      // Print exact error message as requested
      print('[SupabaseService.fetchStoreInventory] Error fetching inventory for store_id $storeId: $e');
      print(stack);
      return [];
    }
  }

  Future<List<ProductModel>> fetchProductsForStore(String storeId) async {
    return fetchStoreInventory(storeId);
  }
}
