import 'package:flutter/material.dart';
import '../models/delivery_order.dart';
import '../widgets/item_picking_tile.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  final DeliveryOrderModel? activeOrder;
  final Function(DeliveryOrderStatus) onUpdateStatus;
  final Function(String itemId, int qty) onMarkPicked;
  final Function(String itemId, String? subName, String? subNote)
  onMarkOutOfStock;
  final Function(String proofNote) onCompleteDelivery;

  const ActiveDeliveryScreen({
    super.key,
    required this.activeOrder,
    required this.onUpdateStatus,
    required this.onMarkPicked,
    required this.onMarkOutOfStock,
    required this.onCompleteDelivery,
  });

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  final TextEditingController _proofNoteController = TextEditingController();
  final TextEditingController _substituteNameController =
      TextEditingController();

  @override
  void dispose() {
    _proofNoteController.dispose();
    _substituteNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = widget.activeOrder;

    if (order == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bike_outlined,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Delivery Batch',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Accept an order from the Available Orders tab to start your picking & delivery route.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Stage Stepper Header
        _buildStageHeader(context, order.status),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Order Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.orderNumber,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Customer: ${order.customerName}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Chip(
                            avatar: const Icon(
                              Icons.attach_money,
                              size: 16,
                              color: Colors.green,
                            ),
                            label: Text(
                              '\$${order.totalPayout.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            backgroundColor: Colors.green.shade50,
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.customerAddress,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (order.deliveryInstructions != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notes,
                                size: 16,
                                color: Colors.amber.shade900,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Customer Note: ${order.deliveryInstructions}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Dynamic Stage Views
                if (order.status == DeliveryOrderStatus.accepted)
                  _buildNavToStoreStage(context, order)
                else if (order.status == DeliveryOrderStatus.arrivedAtStore ||
                    order.status == DeliveryOrderStatus.pickingItems)
                  _buildPickingStage(context, order)
                else if (order.status == DeliveryOrderStatus.inTransit)
                  _buildNavToCustomerStage(context, order)
                else if (order.status == DeliveryOrderStatus.arrivedAtCustomer)
                  _buildDropoffStage(context, order),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStageHeader(BuildContext context, DeliveryOrderStatus status) {
    final stages = [
      {'title': 'Store Nav', 'status': DeliveryOrderStatus.accepted},
      {'title': 'Item Pick', 'status': DeliveryOrderStatus.pickingItems},
      {'title': 'In Transit', 'status': DeliveryOrderStatus.inTransit},
      {'title': 'Dropoff', 'status': DeliveryOrderStatus.arrivedAtCustomer},
    ];

    return Container(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stages.map((s) {
          final sStatus = s['status'] as DeliveryOrderStatus;
          final isActive =
              status == sStatus ||
              (status == DeliveryOrderStatus.arrivedAtStore &&
                  sStatus == DeliveryOrderStatus.pickingItems);
          return Column(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isActive
                    ? Colors.amber.shade700
                    : Colors.grey.shade300,
                child: Icon(
                  isActive ? Icons.check : Icons.circle,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s['title'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? Colors.amber.shade900
                      : Colors.grey.shade700,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavToStoreStage(BuildContext context, DeliveryOrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.storefront, size: 48, color: Colors.blue),
          const SizedBox(height: 12),
          Text(
            'Head to ${order.storeName}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            order.storeAddress,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                widget.onUpdateStatus(DeliveryOrderStatus.arrivedAtStore),
            icon: const Icon(Icons.pin_drop),
            label: const Text('I Have Arrived at Store'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickingStage(BuildContext context, DeliveryOrderModel order) {
    final pickedCount = order.pickedItemCount;
    final totalCount = order.totalItemCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Store Picking Checklist',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '$pickedCount / $totalCount items',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        ...order.items.map(
          (item) => ItemPickingTile(
            item: item,
            onMarkPicked: (qty) => widget.onMarkPicked(item.id, qty),
            onMarkOutOfStock: () => _showSubstitutionDialog(context, item),
          ),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              widget.onUpdateStatus(DeliveryOrderStatus.inTransit);
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Finish Packing & Start Delivery Drive'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavToCustomerStage(
    BuildContext context,
    DeliveryOrderModel order,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            size: 54,
            color: Colors.amber,
          ),
          const SizedBox(height: 12),
          const Text(
            'En Route to Customer Location',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Deliver to: ${order.customerName}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            order.customerAddress,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                widget.onUpdateStatus(DeliveryOrderStatus.arrivedAtCustomer),
            icon: const Icon(Icons.home),
            label: const Text('Arrived at Delivery Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade800,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropoffStage(BuildContext context, DeliveryOrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(Icons.task_alt, size: 54, color: Colors.green),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Proof of Delivery Verification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _proofNoteController,
            decoration: const InputDecoration(
              labelText: 'Delivery Dropoff Note / Photo Confirmation',
              hintText:
                  'e.g. Left safely on front doorstep behind porch pillar.',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final note = _proofNoteController.text.trim().isEmpty
                  ? 'Left at door as requested'
                  : _proofNoteController.text.trim();
              widget.onCompleteDelivery(note);
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Complete Delivery & Collect Earnings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubstitutionDialog(BuildContext context, DeliveryOrderItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Replace/Out-of-Stock: ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter substitute brand/item if found, or leave empty if completely out of stock:',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _substituteNameController,
                decoration: const InputDecoration(
                  labelText: 'Substitute Item Name',
                  hintText: 'e.g. Organic Valley Milk 1 Gal',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onMarkOutOfStock(item.id, null, null);
              },
              child: const Text(
                'Mark Out of Stock',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final sub = _substituteNameController.text.trim();
                Navigator.pop(context);
                widget.onMarkOutOfStock(
                  item.id,
                  sub,
                  'Substituted per customer preference',
                );
                _substituteNameController.clear();
              },
              child: const Text('Save Substitute'),
            ),
          ],
        );
      },
    );
  }
}
