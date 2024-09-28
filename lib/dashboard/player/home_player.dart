import 'package:cricket_club_fyp/configurations/config.dart';
import 'package:cricket_club_fyp/host/widgets/add_match_stats.dart';
import 'package:cricket_club_fyp/player/widgets/add_my_stats.dart';
import 'package:cricket_club_fyp/player/widgets/feedback.dart';
import 'package:cricket_club_fyp/player/widgets/profile_managemnet.dart';
import 'package:cricket_club_fyp/player/widgets/saved_events.dart';
import 'package:cricket_club_fyp/player/widgets/upcoming_events.dart';
import 'package:cricket_club_fyp/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../club/home_club.dart';
import 'package:cricket_club_fyp/player/widgets/my_stats.dart';
class PlayerHome extends StatefulWidget {
  const PlayerHome({@required this.token, @required this.logout,super.key});


  final Function(BuildContext)? logout;
  final String? token;

  @override
  _PlayerHomeState createState() => _PlayerHomeState();
}

class _PlayerHomeState extends State<PlayerHome> {
  int _selectedIndex = 0;
  final Color customColor3 = const Color(0xFF088395);
  bool _isDropdownOpen = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<String?> getUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('_id');
    } catch (e) {
      print('Failed to fetch user ID: $e');
      return null;
    }
  }

  void _fetchUserName() async {
    try {
      print('Starting to fetch user name...');
      String? userId = await getUserId();

      if (userId == null) {
        print('User ID not found, cannot fetch user details');
        return;
      }

      Future<void> storeUserId(String userId) async {
        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('_id', userId);
          print('User ID $userId has been saved successfully.');
        } catch (e) {
          print('Failed to store user ID: $e');
        }
      }

      print("Fetching user details for user ID: $userId");
      final response = await http.get(Uri.parse('$getuserdetails$userId'));

      print("Server response status: ${response.statusCode}");
      print("Server response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == true && data.containsKey('user')) {
          final user = data['user'];
          setState(() {
            _userName = user['name'];
          });
          print("User name set to: $_userName");

          if (userId != user['_id']) {
            await storeUserId(user['_id']);
          }
        } else {
          print('Invalid response structure or status.');
        }
      } else {
        print('Failed to load user details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user details: $error');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UpcomingEventsScreen()),
        );
        break;
      case 3:

        break;
    }
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _onDashboardSelected(String selectedDashboard) {
    if (selectedDashboard == 'Host Dashboard') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClubHome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Player Dashboard',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: customColor3),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    icon: Icon(
                      Icons.switch_account,
                      color: _isDropdownOpen ? customColor3 : Colors.grey,
                    ),
                    items: <String>['Player Dashboard', 'Host Dashboard']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      _toggleDropdown();
                      if (newValue != null) {
                        _onDashboardSelected(newValue);
                      }
                    },
                    onTap: () {
                      _toggleDropdown();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome, ${_userName ?? 'Loading...'}',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              padding: EdgeInsets.all(16.0),
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: <Widget>[
                _buildFeatureCard(Icons.person, "Profile Management"),
                _buildFeatureCard(Icons.insights, "My Statistics"),
                _buildFeatureCard(Icons.data_exploration, "Add New Statistics"),
                _buildFeatureCard(Icons.save, "Saved Events"),
                _buildFeatureCard(Icons.event, "Upcoming Events"),
                _buildFeatureCard(Icons.feedback, "Feedback"),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: customColor3,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        iconSize: 30.0,
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () {
      if (title == "My Statistics") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyStatisticsScreen()),
        );
      } else if (title == "Upcoming Events") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UpcomingEventsScreen()),
        );
      }
      else if (title == "Feedback") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HelpandSupport()),
        );
      }
      else if (title == "Profile Management") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileManagementScreen()),
        );
      }else if (title == "Saved Events") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SavedEvents()),
        );
      }else if (title == "Add New Statistics") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddStatisticsScreen()),
        );
      }
  },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 50.0,
              color: customColor3,
            ),
            SizedBox(height: 10.0),
            Text(
              title,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
