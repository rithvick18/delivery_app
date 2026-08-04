import 'package:flutter/material.dart';
import 'providers/delivery_provider.dart';
import 'theme/app_theme.dart';
import 'views/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SolarisDeliveryApp());
}

class SolarisDeliveryApp extends StatefulWidget {
  const SolarisDeliveryApp({super.key});

  @override
  State<SolarisDeliveryApp> createState() => _SolarisDeliveryAppState();
}

class _SolarisDeliveryAppState extends State<SolarisDeliveryApp> {
  late final DeliveryProvider _deliveryProvider;

  @override
  void initState() {
    super.initState();
    _deliveryProvider = DeliveryProvider();
  }

  @override
  void dispose() {
    _deliveryProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solaris Gold Delivery Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainNavigationScreen(
        deliveryProvider: _deliveryProvider,
      ),
    );
  }
}
