import 'package:flutter/material.dart';

class OnlineToggleBar extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;

  const OnlineToggleBar({
    super.key,
    required this.isOnline,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.shade700 : Colors.grey.shade800,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? Colors.greenAccent : Colors.grey.shade400,
                boxShadow: isOnline
                    ? [
                        const BoxShadow(
                          color: Colors.greenAccent,
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isOnline ? 'YOU ARE ONLINE' : 'YOU ARE OFFLINE',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    isOnline
                        ? 'Receiving high-pay grocery delivery offers'
                        : 'Toggle online to receive new orders',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: isOnline,
              onChanged: onToggle,
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.greenAccent.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
