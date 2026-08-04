import 'package:flutter/material.dart';
import '../models/delivery_order.dart';
import '../models/driver_profile.dart';
import '../services/supabase_service.dart';

class DeliveryProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  DriverProfileModel _driver = DriverProfileModel.sampleDriver;
  List<DeliveryOrderModel> _availableOrders = [];
  List<DeliveryOrderModel> _completedOrders = [];
  DeliveryOrderModel? _activeOrder;

  bool _isLoading = false;
  String? _errorMessage;
  String _filterCategory = 'All';

  DriverProfileModel get driver => _driver;
  List<DeliveryOrderModel> get availableOrders => List.unmodifiable(_availableOrders);
  List<DeliveryOrderModel> get completedOrders => List.unmodifiable(_completedOrders);
  DeliveryOrderModel? get activeOrder => _activeOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filterCategory => _filterCategory;

  DeliveryProvider() {
    _initOrders();
  }

  void _initOrders() {
    _availableOrders = List.from(DeliveryOrderModel.sampleOrders);
    notifyListeners();
  }

  void toggleOnlineStatus() {
    _driver.isOnline = !_driver.isOnline;
    notifyListeners();
  }

  void updateVehicleType(VehicleType type) {
    _driver.vehicleType = type;
    notifyListeners();
  }

  void setFilterCategory(String cat) {
    _filterCategory = cat;
    notifyListeners();
  }

  bool acceptOrder(String orderId) {
    if (_activeOrder != null) {
      _errorMessage = 'You already have an active delivery batch in progress!';
      notifyListeners();
      return false;
    }

    final index = _availableOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _availableOrders.removeAt(index);
      order.status = DeliveryOrderStatus.accepted;
      order.acceptedAt = DateTime.now();
      _activeOrder = order;
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  void updateOrderStatus(DeliveryOrderStatus newStatus) {
    if (_activeOrder != null) {
      _activeOrder!.status = newStatus;
      if (newStatus == DeliveryOrderStatus.completed) {
        _activeOrder!.completedAt = DateTime.now();
        _completedOrders.insert(0, _activeOrder!);
        
        // Update driver stats
        _driver = DriverProfileModel(
          id: _driver.id,
          name: _driver.name,
          email: _driver.email,
          phone: _driver.phone,
          avatarUrl: _driver.avatarUrl,
          rating: _driver.rating,
          totalDeliveries: _driver.totalDeliveries + 1,
          acceptanceRate: _driver.acceptanceRate,
          completionRate: _driver.completionRate,
          isOnline: _driver.isOnline,
          vehicleType: _driver.vehicleType,
          vehicleLicensePlate: _driver.vehicleLicensePlate,
          todayEarnings: _driver.todayEarnings + _activeOrder!.totalPayout,
          weekEarnings: _driver.weekEarnings + _activeOrder!.totalPayout,
        );

        _activeOrder = null;
      }
      notifyListeners();
    }
  }

  void markItemPicked(String itemId, int quantity) {
    if (_activeOrder == null) return;
    final itemIndex = _activeOrder!.items.indexWhere((i) => i.id == itemId);
    if (itemIndex != -1) {
      _activeOrder!.items[itemIndex].status = DeliveryItemStatus.picked;
      _activeOrder!.items[itemIndex].pickedQuantity = quantity;
      notifyListeners();
    }
  }

  void markItemOutOfStock(String itemId, {String? substituteName, String? substituteNote}) {
    if (_activeOrder == null) return;
    final itemIndex = _activeOrder!.items.indexWhere((i) => i.id == itemId);
    if (itemIndex != -1) {
      if (substituteName != null && substituteName.isNotEmpty) {
        _activeOrder!.items[itemIndex].status = DeliveryItemStatus.substituted;
        _activeOrder!.items[itemIndex].substituteItemName = substituteName;
        _activeOrder!.items[itemIndex].substituteNote = substituteNote;
      } else {
        _activeOrder!.items[itemIndex].status = DeliveryItemStatus.outOfStock;
        _activeOrder!.items[itemIndex].pickedQuantity = 0;
      }
      notifyListeners();
    }
  }

  void completeDeliveryWithProof(String proofNote) {
    if (_activeOrder != null) {
      _activeOrder!.proofOfDeliveryNote = proofNote;
      updateOrderStatus(DeliveryOrderStatus.completed);
    }
  }

  void resetDemoData() {
    _activeOrder = null;
    _completedOrders.clear();
    _availableOrders = List.from(DeliveryOrderModel.sampleOrders);
    _driver = DriverProfileModel.sampleDriver;
    notifyListeners();
  }
}
