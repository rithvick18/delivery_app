import 'package:flutter/material.dart';
import '../models/store.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/active_order_banner.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/store_card.dart';

class StoreSelectionScreen extends StatefulWidget {
  final CartProvider provider;
  final VoidCallback onNavigateToCatalog;

  const StoreSelectionScreen({
    super.key,
    required this.provider,
    required this.onNavigateToCatalog,
  });

  @override
  State<StoreSelectionScreen> createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends State<StoreSelectionScreen> {
  String _selectedFilter = 'All Stores';
  String _searchQuery = '';

  final List<String> _filters = [
    'All Stores',
    'Open Now',
    'Live Stock Sync',
    '30 Min Delivery',
    'Curbside Pickup'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.provider.stores.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.provider.fetchStores();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final selectedStore = widget.provider.selectedStore;
        final allStores = widget.provider.stores.isNotEmpty
            ? widget.provider.stores
            : StoreModel.sampleStores;

        final filteredStores = allStores.where((s) {
          final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.address.toLowerCase().contains(_searchQuery.toLowerCase());

          if (_selectedFilter == 'All Stores') return matchesSearch;
          return matchesSearch && s.tags.contains(_selectedFilter);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '742 Evergreen Terrace',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.primary),
                  ],
                ),
                Text(
                  'Store Selection Hub',
                  style: AppTypography.headlineMobile.copyWith(fontSize: 20),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.onSurface),
                onPressed: () {},
              ),
            ],
          ),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ActiveOrderBanner(provider: widget.provider),
                        // Search Bar
                        CustomSearchBar(
                          hintText: 'Search stores or addresses...',
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Active Selected Store Banner
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryContainer, Color(0xFFFBBF24)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'CURRENTLY SELECTED',
                                      style: AppTypography.labelCaps.copyWith(
                                        fontSize: 10,
                                        color: AppColors.onPrimaryContainer,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.check_circle, color: AppColors.onPrimaryContainer, size: 20),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                selectedStore.name,
                                style: AppTypography.headlineMobile.copyWith(
                                  color: AppColors.onPrimaryContainer,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${selectedStore.distanceMiles} mi away • ${selectedStore.deliveryTimeMins} min delivery',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onPrimaryContainer.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: widget.onNavigateToCatalog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.onSurface,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Browse Store Produce Catalog'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filters.map((filter) {
                              final isSelected = _selectedFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(filter),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    if (val) {
                                      setState(() {
                                        _selectedFilter = filter;
                                      });
                                    }
                                  },
                                  selectedColor: AppColors.primaryContainer,
                                  backgroundColor: AppColors.surfaceContainerLowest,
                                  labelStyle: AppTypography.bodySm.copyWith(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.onPrimaryContainer
                                        : AppColors.onSurfaceVariant,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? AppColors.primaryContainer
                                          : AppColors.outlineVariant,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Nearby Fulfillment Centers (${filteredStores.length})',
                          style: AppTypography.titleMd,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // Store List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final store = filteredStores[index];
                        return StoreCard(
                          store: store,
                          isSelected: store.id == selectedStore.id,
                          onTap: () {
                            widget.provider.selectStore(store);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Switched store to ${store.name}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredStores.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          ),
        );
      },
    );
  }
}
