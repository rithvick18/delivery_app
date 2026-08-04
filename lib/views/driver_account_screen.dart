import 'package:flutter/material.dart';
import '../models/driver_profile.dart';

class DriverAccountScreen extends StatelessWidget {
  final DriverProfileModel driver;
  final ValueChanged<VehicleType> onVehicleChanged;
  final VoidCallback onResetDemo;

  const DriverAccountScreen({
    super.key,
    required this.driver,
    required this.onVehicleChanged,
    required this.onResetDemo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Header Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(driver.avatarUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(driver.email, style: theme.textTheme.bodySmall),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '⭐ ${driver.rating} Gold Driver',
                                style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Vehicle Settings Tile
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Vehicle & Logistics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: const Text('Vehicle Type'),
                    trailing: DropdownButton<VehicleType>(
                      value: driver.vehicleType,
                      onChanged: (val) {
                        if (val != null) onVehicleChanged(val);
                      },
                      items: VehicleType.values
                          .map((v) => DropdownMenuItem(
                                value: v,
                                child: Text(v.name.toUpperCase()),
                              ))
                          .toList(),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('License Plate'),
                    subtitle: Text(driver.vehicleLicensePlate),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Demo Controls Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.refresh, color: Colors.amber),
              title: const Text('Reset Demo Orders & Earnings'),
              subtitle: const Text('Restore sample delivery orders and reset stats'),
              onTap: () {
                onResetDemo();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo delivery orders reset successfully!')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
