import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/store.dart';
import '../models/product.dart';
import '../models/live_order.dart';
import '../models/replacement_preference.dart';
import '../services/supabase_service.dart';

/// Central state provider managing cart items, store selection, live order state, and replacement preferences.
class CartProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  StoreModel _selectedStore = StoreModel.sampleStores.first;
  List<StoreModel> _stores = [];
  bool _isLoadingStores = false;
  String? _storesError;

  List<ProductModel> _products = [];
  bool _isLoadingProducts = false;
  String? _productsError;

  final Map<String, int> _cartQuantities = {};
  final LiveOrderModel _liveOrder = LiveOrderModel.sampleLiveOrder;
  ReplacementPreferenceModel _preferences =
      ReplacementPreferenceModel.samplePreferences;
  ReplacementDecisionStatus _replacementDecision =
      ReplacementDecisionStatus.pending;
  String? _selectedReplacementId;

  bool _hasActiveOrder = false;

  StoreModel get selectedStore => _selectedStore;
  List<StoreModel> get stores => _stores;
  bool get isLoadingStores => _isLoadingStores;
  String? get storesError => _storesError;

  List<ProductModel> get products => _products;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get productsError => _productsError;

  Map<String, int> get cartQuantities => Map.unmodifiable(_cartQuantities);
  LiveOrderModel get liveOrder => _liveOrder;
  ReplacementPreferenceModel get preferences => _preferences;
  ReplacementDecisionStatus get replacementDecision => _replacementDecision;
  String? get selectedReplacementId => _selectedReplacementId;
  bool get hasActiveOrder => _hasActiveOrder;

  int get totalItemCount => _cartQuantities.values.fold(0, (sum, q) => sum + q);

  double get totalPrice {
    double total = 0.0;
    _cartQuantities.forEach((prodId, qty) {
      ProductModel? prod;
      for (final p in _products) {
        if (p.id == prodId) {
          prod = p;
          break;
        }
      }
      if (prod == null) {
        for (final p in ProductModel.sampleProducts) {
          if (p.id == prodId) {
            prod = p;
            break;
          }
        }
      }
      prod ??= _products.isNotEmpty
          ? _products.first
          : ProductModel.sampleProducts.first;
      total += prod.price * qty;
    });
    return total;
  }

  Future<void> fetchStores() async {
    _isLoadingStores = true;
    _storesError = null;
    notifyListeners();

    try {
      final fetched = await _supabaseService.fetchStores();
      if (fetched.isNotEmpty) {
        _stores = fetched;
        _selectedStore = _stores.first;
        debugPrint(
          '[CartProvider.fetchStores] Auto-selected first store: ${_selectedStore.name} (${_selectedStore.id})',
        );
        await fetchProductsForStore(_selectedStore.id);
      } else {
        debugPrint(
          '[CartProvider.fetchStores] Empty stores fetched, using fallback sample stores',
        );
        _stores = StoreModel.sampleStores;
        _selectedStore = _stores.first;
        await fetchProductsForStore(_selectedStore.id);
      }
    } catch (e) {
      _storesError = e.toString();
      debugPrint('[CartProvider.fetchStores] Error: $_storesError');
      _stores = StoreModel.sampleStores;
      _selectedStore = _stores.first;
      await fetchProductsForStore(_selectedStore.id);
    } finally {
      _isLoadingStores = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductsForStore(String storeId) async {
    _isLoadingProducts = true;
    _productsError = null;
    notifyListeners();

    try {
      final fetched = await _supabaseService.fetchStoreInventory(storeId);
      if (fetched.isNotEmpty) {
        _products = fetched;
        debugPrint(
          '[CartProvider.fetchProductsForStore] Loaded ${_products.length} products for store: $storeId',
        );
      } else {
        debugPrint(
          '[CartProvider.fetchProductsForStore] Empty products fetched, using fallback sample products',
        );
        _products = ProductModel.sampleProducts;
      }
    } catch (e) {
      _productsError = e.toString();
      debugPrint('[CartProvider.fetchProductsForStore] Error: $_productsError');
      _products = ProductModel.sampleProducts;
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  void selectStore(StoreModel store) {
    _selectedStore = store;
    notifyListeners();
    fetchProductsForStore(store.id);
  }

  int getQuantity(String productId) {
    return _cartQuantities[productId] ?? 0;
  }

  void incrementQuantity(String productId) {
    _cartQuantities[productId] = (_cartQuantities[productId] ?? 0) + 1;
    notifyListeners();
  }

  void decrementQuantity(String productId) {
    if (_cartQuantities.containsKey(productId)) {
      final current = _cartQuantities[productId]!;
      if (current > 1) {
        _cartQuantities[productId] = current - 1;
      } else {
        _cartQuantities.remove(productId);
      }
      notifyListeners();
    }
  }

  void approveReplacement(String replacementId) {
    _replacementDecision = ReplacementDecisionStatus.approved;
    _selectedReplacementId = replacementId;
    notifyListeners();
  }

  void declineReplacement() {
    _replacementDecision = ReplacementDecisionStatus.declined;
    _selectedReplacementId = null;
    notifyListeners();
  }

  void updateGlobalStrategy(GlobalReplacementStrategy strategy) {
    _preferences = ReplacementPreferenceModel(
      defaultStrategy: strategy,
      allowPriceIncreaseUpTo20Pct: _preferences.allowPriceIncreaseUpTo20Pct,
      preferOrganicIfOriginalOrganic:
          _preferences.preferOrganicIfOriginalOrganic,
      categoryPreferences: _preferences.categoryPreferences,
    );
    notifyListeners();
  }

  void toggleAllowPriceIncrease(bool val) {
    _preferences = ReplacementPreferenceModel(
      defaultStrategy: _preferences.defaultStrategy,
      allowPriceIncreaseUpTo20Pct: val,
      preferOrganicIfOriginalOrganic:
          _preferences.preferOrganicIfOriginalOrganic,
      categoryPreferences: _preferences.categoryPreferences,
    );
    notifyListeners();
  }

  void togglePreferOrganic(bool val) {
    _preferences = ReplacementPreferenceModel(
      defaultStrategy: _preferences.defaultStrategy,
      allowPriceIncreaseUpTo20Pct: _preferences.allowPriceIncreaseUpTo20Pct,
      preferOrganicIfOriginalOrganic: val,
      categoryPreferences: _preferences.categoryPreferences,
    );
    notifyListeners();
  }

  void placeOrder() {
    _hasActiveOrder = true;
    _cartQuantities.clear();
    notifyListeners();
  }

  void completeOrder() {
    _hasActiveOrder = false;
    notifyListeners();
  }

  void clearCart() {
    _cartQuantities.clear();
    notifyListeners();
  }
}
