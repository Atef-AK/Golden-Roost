import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive.dart';
import '../../models/flock.dart';
import '../../providers/flock_provider.dart';
import '../widgets/chicken_icon.dart';
import '../widgets/empty_state_view.dart';

class FlocksScreen extends ConsumerStatefulWidget {
  const FlocksScreen({super.key});

  @override
  ConsumerState<FlocksScreen> createState() => _FlocksScreenState();
}

class _FlocksScreenState extends ConsumerState<FlocksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allFlocks = ref.watch(flocksProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeFlocks = allFlocks
        .where((f) => !f.isArchived && _matchesSearch(f))
        .toList();
    final archivedFlocks = allFlocks
        .where((f) => f.isArchived && _matchesSearch(f))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('flocks_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: context.tr('flocks_add_new'),
            onPressed: () => context.push('/flocks/new'),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryTeal,
              labelColor: AppColors.primaryTeal,
              unselectedLabelColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.tr('flocks_active')),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          activeFlocks.length.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.tr('flocks_archived')),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          archivedFlocks.length.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_flocks',
        elevation: 2,
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          context.tr('flocks_add_new'),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        onPressed: () => context.push('/flocks/new'),
      ),
      body: ResponsiveContainer(
        maxWidth: 1100,
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: context.tr('flocks_search_hint'),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                onChanged: (val) =>
                    setState(() => _searchQuery = val.trim().toLowerCase()),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFlockList(activeFlocks, isArchivedList: false),
                  _buildFlockList(archivedFlocks, isArchivedList: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesSearch(Flock f) {
    if (_searchQuery.isEmpty) return true;
    return f.name.toLowerCase().contains(_searchQuery) ||
        f.breed.toLowerCase().contains(_searchQuery) ||
        f.species.toLowerCase().contains(_searchQuery) ||
        f.housingLocation.toLowerCase().contains(_searchQuery);
  }

  Widget _buildFlockList(List<Flock> flocks, {required bool isArchivedList}) {
    if (flocks.isEmpty) {
      return EmptyStateView(
        imageAsset: isArchivedList
            ? null
            : 'assets/illustrations/empty_states/empty_flocks.jpg',
        iconWidget: const ChickenIcon(size: 38, color: AppColors.forestEmerald),
        title: isArchivedList
            ? context.tr('flocks_empty_archived_title')
            : context.tr('flocks_empty'),
        description: isArchivedList
            ? context.tr('flocks_empty_archived_desc')
            : context.tr('flocks_empty_desc'),
        buttonText: isArchivedList ? null : context.tr('flocks_add_new'),
        onButtonPressed: isArchivedList
            ? null
            : () => context.push('/flocks/new'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        if (isWide) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.1,
            ),
            itemCount: flocks.length,
            itemBuilder: (ctx, index) => _FlockCard(flock: flocks[index]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          itemCount: flocks.length,
          itemBuilder: (ctx, index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FlockCard(flock: flocks[index]),
          ),
        );
      },
    );
  }
}

class _FlockCard extends StatelessWidget {
  final Flock flock;

  const _FlockCard({required this.flock});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mortalityCount = flock.startCount > flock.currentCount
        ? (flock.startCount - flock.currentCount)
        : 0;
    final mortalityPct = flock.startCount > 0
        ? (mortalityCount / flock.startCount) * 100
        : 0.0;

    final (speciesIcon, speciesColor) = AppIcons.getSpeciesVisual(
      flock.species,
    );

    return PremiumCard(
      onTap: () => context.push('/flocks/${flock.id}'),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: speciesColor.withAlpha(24),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: speciesColor.withAlpha(50),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child:
                            flock.species.toLowerCase().contains('layer') ||
                                flock.species.toLowerCase().contains('pond')
                            ? Icon(
                                Icons.egg_rounded,
                                color: speciesColor,
                                size: 20,
                              )
                            : (flock.species.toLowerCase().contains('chick') ||
                                      flock.species.toLowerCase().contains(
                                        'poussin',
                                      )
                                  ? Icon(
                                      Icons.child_care_rounded,
                                      color: speciesColor,
                                      size: 20,
                                    )
                                  : (flock.species.toLowerCase().contains(
                                              'duck',
                                            ) ||
                                            flock.species
                                                .toLowerCase()
                                                .contains('canard')
                                        ? Icon(
                                            Icons.water_outlined,
                                            color: speciesColor,
                                            size: 20,
                                          )
                                        : (flock.species.toLowerCase().contains(
                                                    'turkey',
                                                  ) ||
                                                  flock.species
                                                      .toLowerCase()
                                                      .contains('dinde')
                                              ? Icon(
                                                  Icons.pets_rounded,
                                                  color: speciesColor,
                                                  size: 20,
                                                )
                                              : ChickenIcon(
                                                  color: speciesColor,
                                                  size: 20,
                                                )))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flock.name,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${context.trSpecies(flock.species)} • ${flock.breed.isNotEmpty ? flock.breed : context.tr('flocks_standard_breed')}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (flock.housingLocation.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  AppIcons.coop,
                                  size: 12,
                                  color: isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiaryLight,
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    flock.housingLocation,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge.info(context.trPurpose(flock.purpose)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.pageBackgroundDark
                  : const Color(0xFFF8FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatCell(
                  label: context.tr('dash_total_birds'),
                  value: '${flock.currentCount}',
                  subtext: '${context.tr('flocks_of')} ${flock.startCount}',
                  valueColor: AppColors.primaryTeal,
                ),
                _StatCell(
                  label: context.tr('flocks_age'),
                  value: '${flock.ageInDays}${context.tr('flocks_days_short')}',
                  subtext:
                      '${flock.ageInWeeks} ${context.tr('flocks_weeks_short')}',
                ),
                _StatCell(
                  label: context.tr('flocks_mortality'),
                  value: '${mortalityPct.toStringAsFixed(1)}%',
                  subtext: '$mortalityCount ${context.tr('flocks_lost')}',
                  valueColor: mortalityPct > 5.0 ? AppColors.error : null,
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final Color? valueColor;

  const _StatCell({
    required this.label,
    required this.value,
    required this.subtext,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color:
                    valueColor ??
                    (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
          ),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 9.5,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
