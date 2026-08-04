enum VehicleType {
  car,
  scooter,
  bicycle,
  van,
}

class DriverProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final double rating;
  final int totalDeliveries;
  final double acceptanceRate; // e.g. 98.5%
  final double completionRate; // e.g. 99.2%
  bool isOnline;
  VehicleType vehicleType;
  final String vehicleLicensePlate;
  final double todayEarnings;
  final double weekEarnings;

  DriverProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.rating,
    required this.totalDeliveries,
    required this.acceptanceRate,
    required this.completionRate,
    this.isOnline = true,
    this.vehicleType = VehicleType.car,
    required this.vehicleLicensePlate,
    required this.todayEarnings,
    required this.weekEarnings,
  });

  static DriverProfileModel get sampleDriver => DriverProfileModel(
    id: 'drv_7749',
    name: 'Alex Rivera',
    email: 'alex.rivera@solarisdelivery.com',
    phone: '+1 (555) 438-9920',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&fit=crop',
    rating: 4.94,
    totalDeliveries: 428,
    acceptanceRate: 97.5,
    completionRate: 99.1,
    isOnline: true,
    vehicleType: VehicleType.car,
    vehicleLicensePlate: '7XYZ-892',
    todayEarnings: 84.50,
    weekEarnings: 562.80,
  );
}
