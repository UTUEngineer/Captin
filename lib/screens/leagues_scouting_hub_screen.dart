import 'package:flutter/material.dart';
import 'package:captain/features/scouting/player_profile_screen.dart';

class LeaguesScoutingHubScreen extends StatelessWidget {
  const LeaguesScoutingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E131F),
        appBar: AppBar(
          title: const Text('Section 3: Leagues, Teams & Players'),
          backgroundColor: const Color(0xFF1A2234),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF9100),
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.emoji_events), text: 'Competitions'),
              Tab(icon: Icon(Icons.badge), text: 'Player Intel'),
              Tab(icon: Icon(Icons.psychology), text: 'Claude AI Scouting'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LeaguesListView(),
            _PlayerProfilesDatabaseView(),
            _AiScoutingReportsView(),
          ],
        ),
      ),
    );
  }
}

class _LeaguesListView extends StatefulWidget {
  const _LeaguesListView();

  @override
  State<_LeaguesListView> createState() => _LeaguesListViewState();
}

class _LeaguesListViewState extends State<_LeaguesListView> {
  String _selectedLeague = 'Iraq Stars League';

  final List<Map<String, dynamic>> _leaguesData = [
    {
      'name': 'Iraq Stars League',
      'arabicName': 'دوري نجوم العراق',
      'country': 'Iraq 🇮🇶',
      'teamsCount': 20,
      'teams': ['Al-Shorta SC', 'Al-Quwa Al-Jawiya', 'Al-Zawraa SC', 'Erbil SC', 'Zakho SC'],
    },
    {
      'name': 'Premier League',
      'arabicName': 'الدوري الإنجليزي الممتاز',
      'country': 'England 🏴󠁧󠁢󠁥󠁮󠁧󠁿',
      'teamsCount': 20,
      'teams': ['Manchester City', 'Arsenal', 'Liverpool', 'Aston Villa', 'Chelsea'],
    },
    {
      'name': 'La Liga',
      'arabicName': 'الدوري الإسباني',
      'country': 'Spain 🇪🇸',
      'teamsCount': 20,
      'teams': ['Real Madrid', 'FC Barcelona', 'Atletico Madrid', 'Girona', 'Athletic Club'],
    },
    {
      'name': 'Serie A',
      'arabicName': 'الدوري الإيطالي',
      'country': 'Italy 🇮🇹',
      'teamsCount': 20,
      'teams': ['Inter Milan', 'AC Milan', 'Juventus', 'Atalanta', 'Roma'],
    },
    {
      'name': 'UEFA Champions League',
      'arabicName': 'دوري أبطال أوروبا',
      'country': 'Europe 🇪🇺',
      'teamsCount': 36,
      'teams': ['Real Madrid', 'Bayern Munich', 'Manchester City', 'PSG', 'Inter'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Select Competition & Squad Data',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Direct integration with official league tables & tactical rosters',
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
        const SizedBox(height: 16),
        for (final league in _leaguesData) _buildLeagueCard(league),
      ],
    );
  }

  Widget _buildLeagueCard(Map<String, dynamic> league) {
    final isSelected = _selectedLeague == league['name'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFFFF9100) : Colors.white12,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: isSelected,
        onExpansionChanged: (expanded) {
          if (expanded) setState(() => _selectedLeague = league['name']);
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9100).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.sports_soccer, color: Color(0xFFFF9100)),
        ),
        title: Text(
          '${league['name']} (${league['arabicName']})',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          '${league['country']} • ${league['teamsCount']} Clubs',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0F172A),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Featured Clubs & Tactical Rosters:',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (league['teams'] as List<String>)
                      .map(
                        (team) => Chip(
                          backgroundColor: const Color(0xFF1E293B),
                          side: BorderSide.none,
                          avatar: const Icon(Icons.shield, size: 16, color: Color(0xFFFF9100)),
                          label: Text(team, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9100),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.file_download_outlined, size: 18),
                    label: const Text('Import Squad to 3D Playground', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Imported ${league['name']} squad into 3D Playground!')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerProfilesDatabaseView extends StatefulWidget {
  const _PlayerProfilesDatabaseView();

  @override
  State<_PlayerProfilesDatabaseView> createState() => _PlayerProfilesDatabaseViewState();
}

class _PlayerProfilesDatabaseViewState extends State<_PlayerProfilesDatabaseView> {
  String _selectedPosition = 'ALL';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _players = [
    {
      'name': 'Ayman Hussein',
      'number': 18,
      'position': 'FWD',
      'club': 'Al-Quwa Al-Jawiya',
      'height': '1.89 m',
      'foot': 'Right',
      'stamina': 92,
      'speed': 85,
      'passAcc': 78,
      'heading': 94,
    },
    {
      'name': 'Ali Jasim',
      'number': 7,
      'position': 'MID',
      'club': 'Como 1907 / Iraq',
      'height': '1.78 m',
      'foot': 'Right',
      'stamina': 88,
      'speed': 91,
      'passAcc': 86,
      'heading': 72,
    },
    {
      'name': 'Ibrahim Bayesh',
      'number': 8,
      'position': 'MID',
      'club': 'Riyadh SC',
      'height': '1.77 m',
      'foot': 'Right',
      'stamina': 94,
      'speed': 87,
      'passAcc': 83,
      'heading': 81,
    },
    {
      'name': 'Zaid Tahseen',
      'number': 4,
      'position': 'DEF',
      'club': 'Al-Shorta SC',
      'height': '1.86 m',
      'foot': 'Right',
      'stamina': 86,
      'speed': 82,
      'passAcc': 80,
      'heading': 89,
    },
    {
      'name': 'Jalal Hassan',
      'number': 12,
      'position': 'GK',
      'club': 'Al-Zawraa SC',
      'height': '1.87 m',
      'foot': 'Right',
      'stamina': 82,
      'speed': 70,
      'passAcc': 74,
      'heading': 65,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _players.where((p) {
      final matchesPos = _selectedPosition == 'ALL' || p['position'] == _selectedPosition;
      final matchesQuery = p['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesPos && matchesQuery;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search player dossier...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFF9100)),
                    filled: true,
                    fillColor: const Color(0xFF161B22),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedPosition,
                dropdownColor: const Color(0xFF161B22),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                items: ['ALL', 'GK', 'DEF', 'MID', 'FWD']
                    .map((pos) => DropdownMenuItem(value: pos, child: Text(pos)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPosition = val);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final player = filtered[index];
              return _buildPlayerCard(player);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlayerProfileScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFFF9100).withValues(alpha: 0.2),
                      child: Text(
                        '#${p['number']}',
                        style: const TextStyle(color: Color(0xFFFF9100), fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name'],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${p['club']} • ${p['position']}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        p['position'],
                        style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statTile('Height', p['height']),
                    _statTile('Foot', p['foot']),
                    _statTile('Speed', '${p['speed']}'),
                    _statTile('Stamina', '${p['stamina']}%'),
                    _statTile('Pass Acc', '${p['passAcc']}%'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

class _AiScoutingReportsView extends StatelessWidget {
  const _AiScoutingReportsView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF9100).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology, size: 36, color: Color(0xFFFF9100)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Claude 3.5 Sonnet Scouting Engine',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'UEFA-Pro Automated Opposition Analysis & Danger Zone Reports',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _reportCard(
          title: 'Opponent High-Press Vulnerability',
          category: 'Tactical Analysis',
          severity: 'HIGH RISK',
          color: const Color(0xFFFF5252),
          summary: 'Opposition triggers 4-3-3 high block at 65m line. Vulnerable to fast diagonal passes into right wing space.',
        ),
        _reportCard(
          title: 'Set Piece Defending Structure',
          category: 'Set Pieces',
          severity: 'MEDIUM',
          color: const Color(0xFFFFD600),
          summary: 'Zonal-man hybrid coverage on corner kicks. Near post area is vulnerable to late runs from central midfielders.',
        ),
        _reportCard(
          title: 'Counter-Attack Danger Zone',
          category: 'Transition Phase',
          severity: 'CRITICAL',
          color: const Color(0xFFFF5252),
          summary: '82% of opponent goals originate from turnover in central midfield half-space. Recommend double pivot protection.',
        ),
      ],
    );
  }

  Widget _reportCard({
    required String title,
    required String category,
    required String severity,
    required Color color,
    required String summary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  severity,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),
          Text(summary, style: TextStyle(color: Colors.grey[300], fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}
