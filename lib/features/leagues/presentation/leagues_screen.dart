import 'package:captain/core/router/app_router.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/domain/league_regions.dart';
import 'package:captain/features/leagues/presentation/widgets/football_api_key_dialog.dart';
import 'package:captain/features/leagues/presentation/widgets/league_tile.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/shared/widgets/empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaguesScreen extends ConsumerStatefulWidget {
  const LeaguesScreen({super.key});

  @override
  ConsumerState<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends ConsumerState<LeaguesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: LeagueRegions.categories.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPreferencesProvider).value;
    final isArabic = prefs?.isArabic ?? true;
    final apiConfigured = ref.watch(footballApiKeyConfiguredProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(
            isArabic ? 'الدوريات' : 'Leagues',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              tooltip: isArabic ? 'مفتاح API' : 'API key',
              onPressed: () => FootballApiKeyDialog.show(context),
              icon: const Icon(Icons.key_outlined),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.pitchGreenLight,
            labelColor: AppColors.pitchGreenLight,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: LeagueRegions.categories
                .map((category) => Tab(text: category.labelAr))
                .toList(),
          ),
        ),
        body: apiConfigured.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _MissingApiKeyView(isArabic: isArabic),
          data: (configured) {
            if (!configured) {
              return _MissingApiKeyView(isArabic: isArabic);
            }

            return TabBarView(
              controller: _tabController,
              children: LeagueRegions.categories
                  .map(
                    (category) => LeaguesList(
                      regionCode: category.code,
                      isArabic: isArabic,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class _MissingApiKeyView extends StatelessWidget {
  const _MissingApiKeyView({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: Icons.public,
      isArabic: isArabic,
      title: isArabic ? 'أضف مفتاح API-Football' : 'Add your API-Football key',
      subtitle: isArabic
          ? 'البيانات الحقيقية للدوريات العراقية والعالمية تتطلب مفتاحاً من api-football.com'
          : 'Live league data requires a free key from api-football.com',
      actionLabel: isArabic ? 'إعداد المفتاح' : 'Configure key',
      onAction: () => FootballApiKeyDialog.show(context),
    );
  }
}
