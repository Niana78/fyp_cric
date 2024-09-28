import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

import '../../configurations/config.dart';
import '../../constants/color_theme.dart';

class ViewOtherUserProfile extends StatefulWidget {
  final String userId;

  const ViewOtherUserProfile({Key? key, required this.userId}) : super(key: key);

  @override
  State<ViewOtherUserProfile> createState() => _ViewOtherUserProfileState();
}

class _ViewOtherUserProfileState extends State<ViewOtherUserProfile> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final response = await http.get(Uri.parse('$getuserdetails${widget.userId}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == true && data.containsKey('user')) {
          final user = data['user'];

          final String? profilePictureUrl = user['profilePictureUrl'];
          final String fullProfilePictureUrl = profilePictureUrl != null
              ? '$baseurl$profilePictureUrl'.replaceAll('\\', '/')
              : _profilePictureUrl;

          setState(() {
            _userData = user;
            _isLoading = false;
            _profilePictureUrl = fullProfilePictureUrl;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'User Profile',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: CricketClubTheme().white,
          ),
        ),
        backgroundColor: CricketClubTheme().eeriesturquoise,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlayerOverview(context),
            SizedBox(height: 16.0),
            _buildPerformanceMetrics(context),
            SizedBox(height: 16.0),
            _buildCharts(),
            SizedBox(height: 16.0),
            _buildAchievements(context),
            SizedBox(height: 16.0),
            _buildMatchLog(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerOverview(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: _profilePictureUrl.isNotEmpty
              ? NetworkImage(Uri.encodeFull(_profilePictureUrl))
              : AssetImage('assets/images/main_logo.png') as ImageProvider,
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userData?['name'] ?? 'N/A',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                _userData?['role'] ?? 'Batsman',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              Text(
                _userData?['team'] ?? 'National Team',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Performance Metrics',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMetricCard(
                  'Matches', _userData?['matches']?.toString() ?? 'N/A'),
              _buildMetricCard('Runs', _userData?['runs']?.toString() ?? 'N/A'),
              _buildMetricCard(
                  'Wickets', _userData?['wickets']?.toString() ?? 'N/A'),
              _buildMetricCard(
                  'Average', _userData?['average']?.toString() ?? 'N/A'),
              _buildMetricCard(
                  'Strike Rate', _userData?['strikeRate']?.toString() ?? 'N/A'),
              _buildMetricCard('Best Score', _userData?['bestScore'] ?? 'N/A'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Card(
      elevation: 4,
      child: Container(
        width: 100,
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text(
                title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts() {
    if (_userData == null || _userData?['matchLog'] == null) {
      return Text('No match data available.');
    }

    List<dynamic>? matchLog = _userData?['matchLog'];
    if (matchLog is! List || matchLog.isEmpty) {
      return Text('No match data available.');
    }

    List<FlSpot> chartData = [];
    for (int i = 0; i < matchLog.length; i++) {
      final log = matchLog[i];
      final runs = double.tryParse(log['runs'].toString()) ?? 0.0;
      chartData.add(FlSpot(i.toDouble(), runs));
    }

    // Handle the case when chartData is empty
    if (chartData.isEmpty) {
      return Text('No valid run data to display.');
    }

    // Optional: if there's only one data point, add a second point to avoid single-point issues
    if (chartData.length == 1) {
      chartData.add(FlSpot(1, chartData[0].y));
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: chartData.length.toDouble() - 1,
          minY: 0,
          maxY: chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10,
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.3),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toString());
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toString());
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black12, width: 1),
          ),
          gridData: FlGridData(show: true),
        ),
      ),
    );
  }

  Widget _buildAchievements(BuildContext context) {
    List<dynamic>? achievements = _userData?['achievements'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Achievements',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: achievements!.map((achievement) =>
                _buildAchievementCard(achievement)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(String title) {
    return Card(
      elevation: 4,
      child: Container(
        width: 100,
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.star, size: 30, color: Colors.amber),
            SizedBox(height: 8.0),
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchLog(BuildContext context) {
    List<dynamic>? matchLog = _userData?['matchLog'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Match Log',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Match')),
              DataColumn(label: Text('Runs')),
              DataColumn(label: Text('Wickets')),
              DataColumn(label: Text('Performance')),
            ],
            rows: matchLog!.map<DataRow>((log) {
              return DataRow(cells: [
                DataCell(Text(log['match'] ?? 'N/A')),
                DataCell(Text(log['runs'].toString())),
                DataCell(Text(log['wickets'].toString())),
                DataCell(Text(log['performance'] ?? 'N/A')),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
