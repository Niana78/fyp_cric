import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../configurations/config.dart';
import '../../constants/color_theme.dart';

class AddMatchStats extends StatefulWidget {
  final String matchId;

  const AddMatchStats({super.key, required this.matchId});

  @override
  State<AddMatchStats> createState() => _AddMatchStatsState();
}

class _AddMatchStatsState extends State<AddMatchStats> {
  final CricketClubTheme theme = CricketClubTheme();

  List<PlayerStats> teamAStats = [];
  List<PlayerStats> teamBStats = [];

  @override
  void initState() {
    super.initState();
    // Initialize with empty PlayerStats objects for each team member
    teamAStats = List.generate(11, (index) => PlayerStats(playerName: ''));
    teamBStats = List.generate(11, (index) => PlayerStats(playerName: ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Stats', style: TextStyle(color: Colors.white)),
        backgroundColor: theme.maincolor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _submitMatchStats,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTeamSection(teamName: "Team A", playerStats: teamAStats),
              const SizedBox(height: 20),
              _buildTeamSection(teamName: "Team B", playerStats: teamBStats),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.maincolor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _submitMatchStats,
                child: const Text('Submit Stats'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSection({required String teamName, required List<PlayerStats> playerStats}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          teamName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildPlayerStatsList(playerStats),
      ],
    );
  }

  Widget _buildPlayerStatsList(List<PlayerStats> playerStats) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: playerStats.length,
      itemBuilder: (context, index) {
        return _buildPlayerCard(playerStats[index]);
      },
    );
  }

  Widget _buildPlayerCard(PlayerStats player) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: player.nameController,
              decoration: const InputDecoration(labelText: "Player Name"),
            ),
            Row(
              children: [
                Expanded(child: _buildStatField(label: "Runs", controller: player.runsController)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatField(label: "Balls Faced", controller: player.ballsFacedController)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildStatField(label: "Wickets", controller: player.wicketsController)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatField(label: "Overs Bowled", controller: player.oversBowledController)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatField({required String label, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }

  Future<void> _submitMatchStats() async {
    try {
      List<Map<String, dynamic>> stats = [];

      // Collect stats from Team A
      teamAStats.forEach((player) {
        if (player.nameController.text.isNotEmpty) {
          stats.add(player.toJson());
        }
      });

      // Collect stats from Team B
      teamBStats.forEach((player) {
        if (player.nameController.text.isNotEmpty) {
          stats.add(player.toJson());
        }
      });

      // Check if stats array is empty
      if (stats.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter stats for at least one player before submitting.')),
        );
        return;
      }

      final uri = Uri.parse('$addmatchstatsofteams${widget.matchId}/stats');
      final body = jsonEncode(stats);

      print("URI: $uri");
      print("Match ID: ${widget.matchId}");
      print("Body: $body");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stats submitted successfully!')),
        );
      } else {
        print("Response Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit stats.')),
        );
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }
}

class PlayerStats {
  String playerName;
  int runs;
  int ballsFaced;
  int wickets;
  int oversBowled;

  TextEditingController nameController;
  TextEditingController runsController;
  TextEditingController ballsFacedController;
  TextEditingController wicketsController;
  TextEditingController oversBowledController;

  PlayerStats({
    required this.playerName,
    this.runs = 0,
    this.ballsFaced = 0,
    this.wickets = 0,
    this.oversBowled = 0,
  })  : nameController = TextEditingController(text: playerName),
        runsController = TextEditingController(text: runs.toString()),
        ballsFacedController = TextEditingController(text: ballsFaced.toString()),
        wicketsController = TextEditingController(text: wickets.toString()),
        oversBowledController = TextEditingController(text: oversBowled.toString());

  Map<String, dynamic> toJson() {
    return {
      "playerName": nameController.text,
      "runs": int.tryParse(runsController.text) ?? 0,
      "ballsFaced": int.tryParse(ballsFacedController.text) ?? 0,
      "wickets": int.tryParse(wicketsController.text) ?? 0,
      "oversBowled": int.tryParse(oversBowledController.text) ?? 0,
    };
  }
}
