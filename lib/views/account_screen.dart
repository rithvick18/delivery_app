import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/active_order_banner.dart';
import 'live_shopping_screen.dart';
import 'replacement_preferences_screen.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  final CartProvider provider;
  final AuthProvider authProvider;

  const AccountScreen({
    super.key,
    required this.provider,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([provider, authProvider]),
      builder: (context, _) {
        final isAuthenticated = authProvider.isAuthenticated;
        final user = authProvider.user;
        final profile = authProvider.profile;

        final String displayName = profile?['full_name'] ??
            user?.userMetadata?['full_name'] ??
            user?.userMetadata?['name'] ??
            (user?.email != null ? user!.email!.split('@').first : 'Guest User');
        final String email = user?.email ?? 'Sign in to access your profile';
        final String? avatarUrl = profile?['avatar_url'] ?? user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];

        String initials = 'SG';
        if (displayName.isNotEmpty && displayName != 'Guest User') {
          final parts = displayName.trim().split(' ');
          if (parts.length >= 2) {
            initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
          } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
            initials = parts[0][0].toUpperCase();
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Account & Profile',
              style: AppTypography.headlineMobile,
            ),
            actions: [
              if (isAuthenticated)
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  tooltip: 'Sign Out',
                  onPressed: () async {
                    await authProvider.signOut();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signed out successfully.')),
                      );
                    }
                  },
                ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface),
                onPressed: () {},
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Header Card / Sign-in prompt
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.surfaceContainerLow, AppColors.surfaceContainerLowest],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          avatarUrl != null && avatarUrl.isNotEmpty
                              ? CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(avatarUrl),
                                  backgroundColor: AppColors.primaryContainer,
                                )
                              : CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColors.primaryContainer,
                                  child: Text(
                                    initials,
                                    style: AppTypography.headlineMobile.copyWith(
                                      color: AppColors.onPrimaryContainer,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        style: AppTypography.titleMd.copyWith(fontSize: 18),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isAuthenticated ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isAuthenticated ? 'GOLD MEMBER' : 'GUEST',
                                        style: AppTypography.labelCaps.copyWith(
                                          fontSize: 9,
                                          color: isAuthenticated ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: AppTypography.bodySm.copyWith(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (!isAuthenticated) ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 34,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LoginScreen(authProvider: authProvider),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      icon: const Icon(Icons.login_rounded, size: 16),
                                      label: Text(
                                        'Continue with Google',
                                        style: AppTypography.bodySm.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Reusable Active Order Banner (If order in progress)
                  ActiveOrderBanner(provider: provider),

                  const SizedBox(height: 16),

                  // Settings Sections
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Ordering Preferences', style: AppTypography.titleMd.copyWith(fontSize: 16)),
                  ),
                  const SizedBox(height: 8),

                  _buildTile(
                    icon: Icons.tune_rounded,
                    title: 'Backup & Replacement Preferences',
                    subtitle: 'Set AI substitution rules & brand guidelines',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReplacementPreferencesScreen(provider: provider),
                        ),
                      );
                    },
                  ),

                  if (provider.hasActiveOrder)
                    _buildTile(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Live Shopper Progress',
                      subtitle: 'Track live shopping activity for Order #${provider.liveOrder.orderId}',
                      iconColor: AppColors.confidenceHigh,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LiveShoppingScreen(provider: provider),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Account & Payments', style: AppTypography.titleMd.copyWith(fontSize: 16)),
                  ),
                  const SizedBox(height: 8),

                  _buildTile(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Delivery Addresses',
                    subtitle: isAuthenticated
                        ? 'Linked to Supabase User (${user?.id.substring(0, 8)}...)'
                        : 'Sign in to save addresses',
                    onTap: () {
                      if (!isAuthenticated) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(authProvider: authProvider),
                          ),
                        );
                      }
                    },
                  ),
                  _buildTile(
                    icon: Icons.credit_card_rounded,
                    title: 'Payment Methods',
                    subtitle: 'Apple Pay, Visa •••• 4920',
                    onTap: () {},
                  ),
                  _buildTile(
                    icon: Icons.receipt_long_rounded,
                    title: 'Order History & Receipts',
                    subtitle: 'View past grocery purchases',
                    onTap: () {},
                  ),
                  _buildTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications & Live Sync',
                    subtitle: 'Out-of-stock SMS and push alerts',
                    onTap: () {},
                  ),

                  const SizedBox(height: 20),

                  // Demo Order State Controls (for quick testing/toggling)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (provider.hasActiveOrder) {
                          provider.completeOrder();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Completed live order simulation.')),
                          );
                        } else {
                          provider.placeOrder();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Started active live order simulation.')),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      icon: Icon(
                        provider.hasActiveOrder ? Icons.check_circle_outline : Icons.play_circle_outline,
                        size: 18,
                      ),
                      label: Text(
                        provider.hasActiveOrder ? 'Simulate Order Completion' : 'Simulate Active Live Order',
                        style: AppTypography.bodySm.copyWith(fontSize: 13),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = AppColors.primary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.titleMd.copyWith(fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTypography.bodySm.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.outline, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
