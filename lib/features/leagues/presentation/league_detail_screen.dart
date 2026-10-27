import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/presentation/widgets/fixtures_tab.dart';
import 'package:captain/features/leagues/presentation/widgets/overview_tab.dart';
import 'package:captain/features/leagues/presentation/widgets/scorers_tab.dart';
import 'package:captain/features/leagues/presentation/widgets/standings_tab.dart';
import 'package:captain/features/leagues/presentation/widgets/teams_tab.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeagueDetailScreen extends ConsumerStatefulWidget {
  const LeagueDetailScreen({super.key, required this.league});

  final League league;

  @override
  ConsumerState<LeagueDetailScreen> createState() => _LeagueDetailScreenState();
}

class _LeagueDetailScreenState extends ConsumerState<LeagueDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final league = widget.league;
    final params = (leagueId: league.id, season: league.season);
    final standings = ref.watch(standingsProvider(params)).value ?? const [];
    final fixtures = ref.watch(fixturesProvider(params)).value ?? const [];
    final played = fixtures.where((f) => f.isFinished).length;
    final progress = fixtures.isEmpty ? 0.0 : played / fixtures.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerScrolled) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 236,
              backgroundColor: AppColors.surface,
              title: innerScrolled ? Text(league.nameAr) : null,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.28),
                        AppColors.surface,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 76, 20, 54),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Color(0x33000000), blurRadius: 10),
                          ],
                        ),
                        child: CachedNetworkImage(
                          imageUrl: league.logo,
                          errorWidget: (_, _, _) => const Icon(
                            Icons.emoji_events_rounded,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              league.nameAr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${league.country} · موسم ${league.season}/${league.season + 1} · ${standings.length} فريق',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 5,
                                backgroundColor: AppColors.surfaceSunken,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'اكتمل ${(progress * 100).round()}% من الموسم',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: 'نظرة عامة'),
                  Tab(text: 'الترتيب'),
                  Tab(text: 'المباريات'),
                  Tab(text: 'الهدافون'),
                  Tab(text: 'الفرق'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              OverviewTab(
                league: league,
                onOpenTab: (i) => _tabController.animateTo(i),
              ),
              StandingsTab(league: league),
              FixturesTab(league: league),
              ScorersTab(league: league),
              TeamsTab(league: league),
            ],
          ),
        ),
      ),
    );
  }
}

class LeagueByIdScreen extends ConsumerWidget {
  const LeagueByIdScreen({super.key, required this.leagueId});

  final int leagueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leagueAsync = ref.watch(leagueByIdProvider(leagueId));

    return leagueAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$error'),
          ),
        ),
      ),
      data: (league) {
        if (league == null) {
          return const Scaffold(
            body: Center(child: Text('League not found')),
          );
        }
        return LeagueDetailScreen(league: league);
      },
    );
  }
}
