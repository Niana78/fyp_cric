import 'package:cricket_club_fyp/constants/color_theme.dart';
import 'package:cricket_club_fyp/constants/const_exports.dart';
import 'package:flutter/material.dart';
import 'package:cricket_club_fyp/models/event_model.dart';
import 'package:intl/intl.dart';

// Define your color theme
class AppColors {
  static const Color primary = Color(0xFF1E88E5);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.grey;
  static const Color shadowColor = Colors.black12;
}

class ViewMatchStats extends StatelessWidget {
  final Event matchEvent;

  const ViewMatchStats({super.key, required this.matchEvent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),

        backgroundColor: CricketClubTheme().eeriesturquoise,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              matchEvent.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              matchEvent.location,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Details
            _buildMatchDetails(matchEvent),
            const SizedBox(height: 16),
            // Player Stats Section
            const Text(
              'Player Stats',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: matchEvent.playerStats.map((player) {
                print('Rendering player card: ${player.playerName}');
                return _buildPlayerStatCard(player);
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Match Notes Section
            if (matchEvent.notes.isNotEmpty) _buildMatchNotes(matchEvent.notes),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchDetails(Event match) {
    String _formatDate(String dateStr) {
      try {
        DateTime date = DateTime.parse(dateStr);
        return DateFormat.yMMMd().format(date);
      } catch (e) {
        return 'Invalid Date';
      }
    }
    final matchDate = _formatDate(match.matchDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date: $matchDate',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Time: ${match.matchTime}',
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          'Host: ${match.host}',
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPlayerStatCard(PlayerStats player) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              player.playerName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Runs', player.runs.toString()),
                _buildStatItem('Wickets', player.wickets.toString()),
                _buildStatItem('Catches', player.catches.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMatchNotes(String notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Match Notes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(notes),
      ],
    );
  }
}
