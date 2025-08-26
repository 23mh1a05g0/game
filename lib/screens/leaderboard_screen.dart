import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/score_badge.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> leaderboard = [];

  @override
  void initState() {
    super.initState();
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList('leaderboard') ?? [];
    setState(() {
      leaderboard = scores.map((e) {
        final parts = e.split('|');
        return {
          'name': parts[0],
          'score': int.parse(parts[1]),
        };
      }).toList();
      leaderboard.sort((a, b) => b['score'].compareTo(a['score']));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Leaderboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: leaderboard.isEmpty
            ? const Center(child: Text('No scores yet!'))
            : ListView.separated(
                itemCount: leaderboard.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final entry = leaderboard[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(entry['name']),
                    trailing: ScoreBadge(
                      label: 'Score',
                      value: '${entry['score']}',
                    ),
                  );
                },
              ),
      ),
    );
  }
}

