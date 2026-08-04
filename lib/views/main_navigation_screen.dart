import 'package:flutter/material.dart';
import '../providers/delivery_provider.dart';
import '../widgets/online_toggle_bar.dart';
import 'orders_feed_screen.dart';
import 'active_delivery_screen.dart';
import 'earnings_screen.dart';
import 'driver_account_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final DeliveryProvider deliveryProvider;

  const MainNavigationScreen({super.key, required this.deliveryProvider});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = widget.deliveryProvider;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final hasActive = provider.activeOrder != null;

        final screens = [
          OrdersFeedScreen(
            availableOrders: provider.availableOrders,
            isOnline: provider.driver.isOnline,
            selectedCategory: provider.filterCategory,
            onCategorySelected: provider.setFilterCategory,
            onAcceptOrder: (id) async {
              final ok = await provider.acceptOrder(id);
              if (ok) {
                setState(() {
                  _currentIndex = 1; // Auto switch to Active Delivery
                });
              } else if (provider.errorMessage != null) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage!),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              }
            },
          ),
          ActiveDeliveryScreen(
            activeOrder: provider.activeOrder,
            onUpdateStatus: provider.updateOrderStatus,
            onMarkPicked: provider.markItemPicked,
            onMarkOutOfStock: (itemId, subName, subNote) =>
                provider.markItemOutOfStock(
                  itemId,
                  substituteName: subName,
                  substituteNote: subNote,
                ),
            onCompleteDelivery: (proof) =>
                provider.completeDeliveryWithProof(proof),
          ),
          EarningsScreen(
            driver: provider.driver,
            completedOrders: provider.completedOrders,
          ),
          DriverAccountScreen(
            driver: provider.driver,
            onVehicleChanged: provider.updateVehicleType,
            onResetDemo: provider.resetDemoData,
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.electric_rickshaw,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Solaris Driver',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              OnlineToggleBar(
                isOnline: provider.driver.isOnline,
                onToggle: (_) => provider.toggleOnlineStatus(),
              ),
              Expanded(child: screens[_currentIndex]),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: Badge(
                  label: Text('${provider.availableOrders.length}'),
                  child: const Icon(Icons.format_list_bulleted),
                ),
                label: 'Available',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: hasActive,
                  backgroundColor: Colors.amber,
                  child: const Icon(Icons.directions_bike),
                ),
                label: 'Active Trip',
              ),
              const NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                label: 'Earnings',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                label: 'Account',
              ),
            ],
          ),
        );
      },
    );
  }
}
