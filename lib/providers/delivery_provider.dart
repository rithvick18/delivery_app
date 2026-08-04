import 'package:flutter/material.dart';
import 'dart:async';
import '../models/delivery_order.dart';
import '../models/driver_profile.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  StreamSubscription<List<Map<String, dynamic>>>? _ordersSubscription;

  DriverProfileModel _driver = DriverProfileModel.sampleDriver;
  List<DeliveryOrderModel> _availableOrders = [];
  List<DeliveryOrderModel> _completedOrders = [];
  DeliveryOrderModel? _activeOrder;

  bool _isLoading = false;
  String? _errorMessage;
  String _filterCategory = 'All';

  DriverProfileModel get driver => _driver;
  List<DeliveryOrderModel> get availableOrders =>
      List.unmodifiable(_availableOrders);
  List<DeliveryOrderModel> get completedOrders =>
      List.unmodifiable(_completedOrders);
  DeliveryOrderModel? get activeOrder => _activeOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filterCategory => _filterCategory;

  DeliveryProvider() {
    _initWithLiveData();
  }

  Future<void> _initWithLiveData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get current user
      final user = _authService.currentUser;
      if (user != null) {
        // Fetch driver profile from Supabase
        await _loadDriverProfile(user.id);

        // Set up realtime order subscription
        _setupRealtimeOrders();

        // Load initial available orders
        await _loadAvailableOrders();
      }
    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
      print('[DeliveryProvider._initWithLiveData] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadDriverProfile(String driverId) async {
    try {
      final profileData = await _supabaseService.fetchDriverProfile(driverId);

      if (profileData != null) {
        _driver = DriverProfileModel(
          id: profileData['id'] ?? driverId,
          name: profileData['full_name'] ?? 'Driver',
          email: profileData['email'] ?? '',
          phone: profileData['phone'] ?? '',
          avatarUrl: profileData['avatar_url'] ?? '',
          rating: (profileData['rating'] as num?)?.toDouble() ?? 4.5,
          totalDeliveries:
              (profileData['total_deliveries'] as num?)?.toInt() ?? 0,
          acceptanceRate:
              (profileData['acceptance_rate'] as num?)?.toDouble() ?? 95.0,
          completionRate:
              (profileData['completion_rate'] as num?)?.toDouble() ?? 98.0,
          isOnline: profileData['is_online'] ?? false,
          vehicleType: _parseVehicleType(
            profileData['vehicle_type']?.toString(),
          ),
          vehicleLicensePlate: profileData['license_plate']?.toString() ?? '',
          todayEarnings:
              (profileData['today_earnings'] as num?)?.toDouble() ?? 0.0,
          weekEarnings:
              (profileData['week_earnings'] as num?)?.toDouble() ?? 0.0,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load driver profile: ${e.toString()}';
      print('[DeliveryProvider._loadDriverProfile] Error: $e');
    }
  }

  VehicleType _parseVehicleType(String? vehicleType) {
    switch (vehicleType?.toLowerCase()) {
      case 'car':
        return VehicleType.car;
      case 'scooter':
        return VehicleType.scooter;
      case 'bicycle':
        return VehicleType.bicycle;
      case 'van':
        return VehicleType.van;
      default:
        return VehicleType.car;
    }
  }

  void _setupRealtimeOrders() {
    _ordersSubscription = _supabaseService.streamAvailableOrders().listen(
      (ordersData) {
        final newOrders = ordersData
            .map((data) => DeliveryOrderModel.fromMap(data))
            .toList();

        // Only update if there are actual changes
        if (_ordersAreDifferent(newOrders)) {
          _availableOrders = newOrders;
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = 'Realtime orders error: ${error.toString()}';
        print('[DeliveryProvider._setupRealtimeOrders] Error: $error');
      },
    );
  }

  bool _ordersAreDifferent(List<DeliveryOrderModel> newOrders) {
    if (_availableOrders.length != newOrders.length) return true;

    for (int i = 0; i < _availableOrders.length; i++) {
      if (_availableOrders[i].id != newOrders[i].id) return true;
    }

    return false;
  }

  Future<void> _loadAvailableOrders() async {
    try {
      _availableOrders = await _supabaseService.fetchAvailableOrders();
    } catch (e) {
      _errorMessage = 'Failed to load available orders: ${e.toString()}';
      print('[DeliveryProvider._loadAvailableOrders] Error: $e');
    }
  }

  Future<void> toggleOnlineStatus() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        bool newStatus = !_driver.isOnline;
        bool success = await _supabaseService.updateDriverOnlineStatus(
          user.id,
          newStatus,
        );

        if (success) {
          _driver.isOnline = newStatus;
          _errorMessage = null;
        } else {
          _errorMessage = 'Failed to update online status';
        }
      }
    } catch (e) {
      _errorMessage = 'Error updating online status: ${e.toString()}';
      print('[DeliveryProvider.toggleOnlineStatus] Error: $e');
    }
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

  Future<bool> acceptOrder(String orderId) async {
    if (_activeOrder != null) {
      _errorMessage = 'You already have an active delivery batch in progress!';
      notifyListeners();
      return false;
    }

    try {
      final index = _availableOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final order = _availableOrders.removeAt(index);

        // Update order status in Supabase
        bool success = await _supabaseService.updateOrderStatus(
          orderId,
          'accepted',
        );

        if (success) {
          order.status = DeliveryOrderStatus.accepted;
          order.acceptedAt = DateTime.now();
          _activeOrder = order;
          _errorMessage = null;
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Failed to accept order';
          notifyListeners();
          return false;
        }
      }
      return false;
    } catch (e) {
      _errorMessage = 'Error accepting order: ${e.toString()}';
      print('[DeliveryProvider.acceptOrder] Error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> updateOrderStatus(DeliveryOrderStatus newStatus) async {
    if (_activeOrder != null) {
      try {
        // Map status to Supabase status strings
        String supabaseStatus;
        switch (newStatus) {
          case DeliveryOrderStatus.accepted:
            supabaseStatus = 'accepted';
            break;
          case DeliveryOrderStatus.arrivedAtStore:
            supabaseStatus = 'arrived_at_store';
            break;
          case DeliveryOrderStatus.pickingItems:
            supabaseStatus = 'picking_items';
            break;
          case DeliveryOrderStatus.inTransit:
            supabaseStatus = 'in_transit';
            break;
          case DeliveryOrderStatus.arrivedAtCustomer:
            supabaseStatus = 'arrived_at_customer';
            break;
          case DeliveryOrderStatus.completed:
            supabaseStatus = 'completed';
            break;
          case DeliveryOrderStatus.cancelled:
            supabaseStatus = 'cancelled';
            break;
          default:
            supabaseStatus = 'pending';
        }

        bool success = await _supabaseService.updateOrderStatus(
          _activeOrder!.id,
          supabaseStatus,
        );

        if (success) {
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
          _errorMessage = null;
        } else {
          _errorMessage = 'Failed to update order status';
        }
      } catch (e) {
        _errorMessage = 'Error updating order status: ${e.toString()}';
        print('[DeliveryProvider.updateOrderStatus] Error: $e');
      }
      notifyListeners();
    }
  }

  Future<void> markItemPicked(String itemId, int quantity) async {
    if (_activeOrder == null) return;
    final itemIndex = _activeOrder!.items.indexWhere((i) => i.id == itemId);
    if (itemIndex != -1) {
      try {
        bool success = await _supabaseService.updateOrderItemStatus(
          _activeOrder!.id,
          itemId,
          'picked',
          pickedQuantity: quantity,
        );

        if (success) {
          _activeOrder!.items[itemIndex].status = DeliveryItemStatus.picked;
          _activeOrder!.items[itemIndex].pickedQuantity = quantity;
          _errorMessage = null;
        } else {
          _errorMessage = 'Failed to update item status';
        }
      } catch (e) {
        _errorMessage = 'Error updating item status: ${e.toString()}';
        print('[DeliveryProvider.markItemPicked] Error: $e');
      }
      notifyListeners();
    }
  }

  Future<void> markItemOutOfStock(
    String itemId, {
    String? substituteName,
    String? substituteNote,
  }) async {
    if (_activeOrder == null) return;
    final itemIndex = _activeOrder!.items.indexWhere((i) => i.id == itemId);
    if (itemIndex != -1) {
      try {
        String status = substituteName != null && substituteName.isNotEmpty
            ? 'substituted'
            : 'out_of_stock';

        bool success = await _supabaseService.updateOrderItemStatus(
          _activeOrder!.id,
          itemId,
          status,
          substituteItemName: substituteName,
          substituteNote: substituteNote,
        );

        if (success) {
          if (substituteName != null && substituteName.isNotEmpty) {
            _activeOrder!.items[itemIndex].status =
                DeliveryItemStatus.substituted;
            _activeOrder!.items[itemIndex].substituteItemName = substituteName;
            _activeOrder!.items[itemIndex].substituteNote = substituteNote;
          } else {
            _activeOrder!.items[itemIndex].status =
                DeliveryItemStatus.outOfStock;
            _activeOrder!.items[itemIndex].pickedQuantity = 0;
          }
          _errorMessage = null;
        } else {
          _errorMessage = 'Failed to update item status';
        }
      } catch (e) {
        _errorMessage = 'Error updating item status: ${e.toString()}';
        print('[DeliveryProvider.markItemOutOfStock] Error: $e');
      }
      notifyListeners();
    }
  }

  Future<void> completeDeliveryWithProof(String proofNote) async {
    if (_activeOrder != null) {
      try {
        bool success = await _supabaseService.completeOrder(
          _activeOrder!.id,
          proofNote,
        );

        if (success) {
          _activeOrder!.proofOfDeliveryNote = proofNote;
          await updateOrderStatus(DeliveryOrderStatus.completed);
        } else {
          _errorMessage = 'Failed to complete delivery';
          notifyListeners();
        }
      } catch (e) {
        _errorMessage = 'Error completing delivery: ${e.toString()}';
        print('[DeliveryProvider.completeDeliveryWithProof] Error: $e');
        notifyListeners();
      }
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
