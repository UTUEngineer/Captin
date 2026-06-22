import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/presentation/widgets/fixtures_tab.dart';
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Row(
            children: [
              CachedNetworkImage(
                imageUrl: widget.league.logo,
                width: 32,
                height: 32,
                errorWidget: (_, __, ___) => const SizedBox(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.league.nameAr,
                  style: const TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.pitchGreenLight,
            labelColor: AppColors.pitchGreenLight,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'الترتيب'),
              Tab(text: 'المباريات'),
              Tab(text: 'الفرق'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            StandingsTab(league: widget.league),
            FixturesTab(league: widget.league),
            TeamsTab(league: widget.league),
          ],
        ),
      ),
    );
  }
}
