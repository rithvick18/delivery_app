import 'package:flutter/material.dart';
import '../models/delivery_order.dart';

class ItemPickingTile extends StatelessWidget {
  final DeliveryOrderItem item;
  final Function(int quantity) onMarkPicked;
  final VoidCallback onMarkOutOfStock;

  const ItemPickingTile({
    super.key,
    required this.item,
    required this.onMarkPicked,
    required this.onMarkOutOfStock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPicked = item.status == DeliveryItemStatus.picked;
    final isOutOfStock = item.status == DeliveryItemStatus.outOfStock;
    final isSubstituted = item.status == DeliveryItemStatus.substituted;

    Color tileBg = theme.colorScheme.surface;
    if (isPicked) {
      tileBg = Colors.green.shade50;
    } else if (isOutOfStock) {
      tileBg = Colors.red.shade50;
    } else if (isSubstituted) {
      tileBg = Colors.amber.shade50;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: tileBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPicked
              ? Colors.green.shade300
              : isOutOfStock
              ? Colors.red.shade300
              : isSubstituted
              ? Colors.amber.shade400
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                // Item Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 54,
                    height: 54,
                    color: Colors.grey.shade200,
                    child: item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.shopping_basket),
                          )
                        : const Icon(Icons.shopping_basket),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Aisle Location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: isPicked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.aisleLocation,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Req: ${item.requestedQuantity}x | \$${item.unitPrice.toStringAsFixed(2)} ea',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge or Check
                if (isPicked)
                  const CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 16,
                    child: Icon(Icons.check, color: Colors.white, size: 18),
                  )
                else if (isOutOfStock)
                  Chip(
                    label: const Text('OOS'),
                    backgroundColor: Colors.red.shade100,
                    labelStyle: TextStyle(
                      color: Colors.red.shade900,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else if (isSubstituted)
                  Chip(
                    label: const Text('Subbed'),
                    backgroundColor: Colors.amber.shade200,
                    labelStyle: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),

            if (isSubstituted && item.substituteItemName != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Substituted with: ${item.substituteItemName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
            ],

            if (!isPicked) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onMarkOutOfStock,
                    icon: const Icon(
                      Icons.remove_shopping_cart,
                      size: 16,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Out of Stock / Sub',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => onMarkPicked(item.requestedQuantity),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: Text('Found (${item.requestedQuantity}x)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
