import 'package:cricket_club_fyp/configurations/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CricketClubTheme {
  static Color eerieTurquoise = const Color(0xFF003300);
  static Color mainColor = const Color(0xFF088395);
}

class AddStatisticsScreen extends StatefulWidget {
  @override
  _AddStatisticsScreenState createState() => _AddStatisticsScreenState();
}

class _AddStatisticsScreenState extends State<AddStatisticsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _matchesController = TextEditingController();
  final TextEditingController _runsController = TextEditingController();
  final TextEditingController _wicketsController = TextEditingController();
  final TextEditingController _averageController = TextEditingController();
  final TextEditingController _strikeRateController = TextEditingController();
  final TextEditingController _bestScoreController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();

  List<Map<String, dynamic>> _matchLogs = [];

  Future<String?> getUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('_id');
    } catch (e) {
      print('Failed to fetch user ID: $e');
      return null;
    }
  }

  Future<void> _submitStatistics() async {
    if (_formKey.currentState?.validate() != true) return;

    Map<String, dynamic> payload = {
      "matches": int.tryParse(_matchesController.text) ?? 0,
      "runs": int.tryParse(_runsController.text) ?? 0,
      "wickets": int.tryParse(_wicketsController.text) ?? 0,
      "average": double.tryParse(_averageController.text) ?? 0.0,
      "strikeRate": double.tryParse(_strikeRateController.text) ?? 0.0,
      "bestScore": _bestScoreController.text,
      "achievements": _achievementsController.text.split(",").map((s) => s.trim()).toList(),
      "matchLog": _matchLogs,
    };

    try {
      String? userId = await getUserId();
      if (userId == null) {
        throw Exception('User ID is null');
      }

      final response = await http.put(
        Uri.parse('$addmatchstats$userId/statistics'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Statistics updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update statistics: ${response.reasonPhrase}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  void _addMatchLog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController matchController = TextEditingController();
        final TextEditingController runsController = TextEditingController();
        final TextEditingController wicketsController = TextEditingController();
        final TextEditingController performanceController = TextEditingController();

        return AlertDialog(
          title: Text('Add Match Log', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildDialogTextField(matchController, 'Match Name'),
                _buildDialogTextField(runsController, 'Runs'),
                _buildDialogTextField(wicketsController, 'Wickets'),
                _buildDialogTextField(performanceController, 'Performance'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _matchLogs.add({
                    "match": matchController.text,
                    "runs": int.tryParse(runsController.text) ?? 0,
                    "wickets": int.tryParse(wicketsController.text) ?? 0,
                    "performance": performanceController.text,
                  });
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Statistics', style: TextStyle(color: Colors.white),),
        backgroundColor: CricketClubTheme.eerieTurquoise,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_matchesController, 'Matches', Icons.sports_cricket),
              _buildTextField(_runsController, 'Runs', Icons.run_circle),
              _buildTextField(_wicketsController, 'Wickets', Icons.sports_baseball),
              _buildTextField(_averageController, 'Average', Icons.analytics, isNumeric: true),
              _buildTextField(_strikeRateController, 'Strike Rate', Icons.speed, isNumeric: true),
              _buildTextField(_bestScoreController, 'Best Score', Icons.star),
              _buildTextField(_achievementsController, 'Achievements (comma separated)', Icons.emoji_events),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _addMatchLog,
                icon: Icon(Icons.add, color: Colors.white,),
                label: Text('Add Match Log', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CricketClubTheme.mainColor,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitStatistics,
                child: Text('Submit', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CricketClubTheme.mainColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: CricketClubTheme.mainColor),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        keyboardType: isNumeric ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      ),
    );
  }

  Widget _buildDialogTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.text,
      ),
    );
  }
}
