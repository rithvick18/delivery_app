import 'package:flutter/material.dart';
import '../models/delivery_order.dart';
import '../widgets/delivery_order_card.dart';

class OrdersFeedScreen extends StatelessWidget {
  final List<DeliveryOrderModel> availableOrders;
  final bool isOnline;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final Function(String) onAcceptOrder;

  const OrdersFeedScreen({
    super.key,
    required this.availableOrders,
    required this.isOnline,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAcceptOrder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isOnline) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.portable_wifi_off_outlined, size: 72, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'You are currently Offline',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Switch the toggle at the top to Online to start viewing and accepting available delivery orders nearby.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    final categories = ['All', 'High Pay (\$15+)', 'Short Distance (<3 mi)', 'Express'];

    return Column(
      children: [
        // Category filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => onCategorySelected(cat),
                  selectedColor: Colors.amber.shade200,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.amber.shade900 : theme.colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Available orders list
        Expanded(
          child: availableOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No Orders Available Right Now',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stay tuned! New grocery delivery offers pop up every few minutes.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: availableOrders.length,
                  itemBuilder: (context, index) {
                    final order = availableOrders[index];
                    return DeliveryOrderCard(
                      order: order,
                      onAccept: () => onAcceptOrder(order.id),
                      onViewDetails: () => _showOrderDetailsBottomSheet(context, order),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showOrderDetailsBottomSheet(BuildContext context, DeliveryOrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Order Manifest ${order.orderNumber}',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Store: ${order.storeName}',
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                  ),

                  const Divider(height: 24),

                  // Payout Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Base Payout:'),
                            Text('\$${order.basePayout.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Customer Tip:'),
                            Text('\$${order.tipAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (order.bonusPay > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Peak Surge Bonus:'),
                              Text('+\$${order.bonusPay.toStringAsFixed(2)}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimated Earnings:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text(
                              '\$${order.totalPayout.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green.shade800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text('Item Shopping List (${order.items.length} types)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  ...order.items.map((item) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.amber.shade100,
                          child: Text('${item.requestedQuantity}x', style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${item.category} • ${item.aisleLocation}'),
                        trailing: Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                      )),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onAcceptOrder(order.id);
                    },
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Accept & Start Delivery Batch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
