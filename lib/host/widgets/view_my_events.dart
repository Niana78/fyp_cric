import 'dart:convert';
import 'package:cricket_club_fyp/configurations/config.dart';
import 'package:cricket_club_fyp/host/widgets/add_match_stats.dart';
import 'package:cricket_club_fyp/host/widgets/edit_match.dart';
import 'package:cricket_club_fyp/host/widgets/view_deatils_and_invite.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cricket_club_fyp/constants/color_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Event {
  final String name;
  final String location;
  final String matchDate;
  final int totalPlayers;
  final String createdBy;
  final String matchTime;
  final String host;
  final String notes;
  final String id;


  Event({
    required this.id,
    required this.name,
    required this.location,
    required this.matchDate,
    required this.totalPlayers,
    required this.createdBy,
    required this.matchTime,
    required this.notes,
    required this.host
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? '',
      host:json['hostName'] ?? 'Javeria',
      name: json['matchName'] ?? '',
      location: json['matchLocation'] ?? '',
      matchDate: json['matchDate'] ?? '',
      totalPlayers: json['totalPlayers'] ?? '',
      createdBy: json['createdBy'] ?? '',
      matchTime: json['matchTime'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}


class MyEventsScreen extends StatefulWidget {
  @override
  _MyEventsScreenState createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Event> _myEvents = [];
  List<Event> _filteredMyEvents = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchMyEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterEvents();
  }

  void _filterEvents() {
    setState(() {
      _filteredMyEvents = _myEvents
          .where((event) => event.name.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchMyEvents() async {
    String? userId = await getUserId();
    if (userId == null) {
      print("User ID not found in SharedPreferences.");
      _showPopup('Error', 'Failed to retrieve user ID. Please log in again.');
      return;
    }

    try {
      final response = await http.get(Uri.parse('$getallmatchbyid$userId'));
      if (response.statusCode == 200) {
        setState(() {
          _myEvents = (json.decode(response.body) as List)
              .map((data) => Event.fromJson(data))
              .toList();
          _filteredMyEvents = _myEvents;
        });
      } else {
        _showPopup('Error', 'Failed to load my events.');
        throw Exception('Failed to load my events');
      }
    } catch (e) {
      print('Exception caught during HTTP request: $e');
      _showPopup('Error', 'An error occurred: $e');
    }
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

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEventOptionsDialog(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CricketClubTheme().maincolor,
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CricketClubTheme().maincolor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  ),
                  icon: const Icon(Icons.sports_cricket),
                  label: const Text("Add Match Stats"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddMatchStats(matchId: event.id,)),
                    );
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CricketClubTheme().eeriesturquoise,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text("View and Invite"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewDeatilsAndInvite(
                          name: event.name,
                          location: event.location,
                          matchDate: event.matchDate,
                          totalPlayers: event.totalPlayers,
                          createdBy: event.createdBy,
                          matchTime: event.matchTime,
                          notes: event.notes,
                          host: event.host
                      )),
                    );
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Event"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditMatch(
                          name: event.name,
                          location: event.location,
                          matchDate: event.matchDate,
                          totalPlayers: event.totalPlayers,
                          createdBy: event.createdBy,
                          matchTime: event.matchTime,
                          notes: event.notes,
                          host: event.host
                      )),
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          "My Events",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: CricketClubTheme().eeriesturquoise,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: CricketClubTheme().maincolor),
                hintText: 'Search events...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: CricketClubTheme().maincolor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: CricketClubTheme().maincolor),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildEventList(_filteredMyEvents),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(List<Event> events) {
    if (events.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return _buildEventCard(events[index]);
      },
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
        onTap: () => _showEventOptionsDialog(event),
      ),
    );
  }
}
