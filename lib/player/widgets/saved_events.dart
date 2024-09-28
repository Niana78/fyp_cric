import 'dart:convert';
import 'package:cricket_club_fyp/player/widgets/view_details_of_any_event.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cricket_club_fyp/constants/const_exports.dart';
import 'package:cricket_club_fyp/constants/color_theme.dart';
import 'package:cricket_club_fyp/models/event_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../configurations/config.dart';

class SavedEvents extends StatefulWidget {
  const SavedEvents({super.key});

  @override
  State<SavedEvents> createState() => _SavedEventsState();
}

class _SavedEventsState extends State<SavedEvents> {
  List<Event> _savedEvents = [];
  String? _userId; // Store user ID here
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserId().then((_) {
      if (_userId != null) {
        _fetchUserDetails(); // Fetch user details to get saved matches
      }
    });
  }

  Future<void> _fetchUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = prefs.getString('_id'); // Default to null if not found
      });
    } catch (e) {
      print('Failed to fetch user ID: $e');
    }
  }

  Future<void> _fetchUserDetails() async {
    if (_userId == null) return;

    final url = '$getuserdetails$_userId';
    print("Fetching user details from URL: $url");
    try {
      final response = await http.get(Uri.parse(url));
      print("Server response status: ${response.statusCode}");
      print("Server response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == true && data.containsKey('user')) {
          final user = data['user'];

          if (user.containsKey('savedMatches')) {
            final savedMatches = List<String>.from(user['savedMatches']);

            // Fetch event details for each saved match ID
            for (String matchId in savedMatches) {
              await _fetchEventDetails(matchId);
            }

            setState(() {
              _isLoading = false;
            });
          } else {
            print('No saved matches found.');
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          print('Invalid response structure or status.');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('Failed to load user details. Status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching user details: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchEventDetails(String matchId) async {
    final eventUrl = '$getmatchdetailsbyid$matchId';
    print(eventUrl);
    try {
      final response = await http.get(Uri.parse(eventUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> eventData = jsonDecode(response.body);
        setState(() {
          _savedEvents.add(Event.fromJson(eventData));
        });
      } else {
        print('Failed to fetch event details for match ID: $matchId');
      }
    } catch (error) {
      print('Error fetching event details for match ID: $matchId - $error');
    }
  }

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Saved Events", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: CricketClubTheme().eeriesturquoise,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _savedEvents.isEmpty
          ? Center(child: Text("No saved events found"))
          : ListView.builder(
        itemCount: _savedEvents.length,
        itemBuilder: (context, index) {
          final event = _savedEvents[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          event.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(event.location),
        trailing: Icon(Icons.arrow_forward_ios, color: CricketClubTheme().maincolor),
        onTap: () {
          if (_userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewDetailsOfAnyEvent(
                  name: event.name,
                  location: event.location,
                  matchDate: event.matchDate,
                  totalPlayers: event.totalPlayers,
                  createdBy: event.createdBy,
                  matchTime: event.matchTime,
                  notes: event.notes,
                  host: event.host,
                  matchId: event.id,
                  userId: _userId!,
                  playerStats: event.playerStats,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
