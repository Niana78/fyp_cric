import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cricket_club_fyp/configurations/config.dart';
import 'package:cricket_club_fyp/constants/color_theme.dart';
import 'package:cricket_club_fyp/models/event_model.dart';
import 'package:cricket_club_fyp/player/widgets/view_details_of_any_event.dart';

class UpcomingEventsScreen extends StatefulWidget {
  @override
  _UpcomingEventsScreenState createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Event> _upcomingEvents = [];
  List<Event> _myEvents = [];
  List<Event> _filteredUpcomingEvents = [];
  List<Event> _filteredMyEvents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _fetchUpcomingEvents();
    _fetchMyEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterEvents();
  }

  void _filterEvents() {
    setState(() {
      _filteredUpcomingEvents = _upcomingEvents
          .where((event) => event.name.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
      _filteredMyEvents = _myEvents
          .where((event) => event.name.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchUpcomingEvents() async {
    try {
      final response = await http.get(Uri.parse(getallmatch));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        print("Raw JSON response: $jsonResponse"); // Debugging line

        setState(() {
          _upcomingEvents = jsonResponse.map((data) {
            final event = Event.fromJson(data);
            print("Parsed Event: ${event.name}, ${event.location}"); // Debugging line
            return event;
          }).toList();

          // Sort the events by date (newest to oldest)
          _upcomingEvents.sort((a, b) => b.matchDate.compareTo(a.matchDate));
          _filteredUpcomingEvents = _upcomingEvents;
        });
      } else {
        print("Error response: ${response.statusCode} - ${response.body}");
        _showPopup('Error', 'Failed to load upcoming events.');
        throw Exception('Failed to load upcoming events');
      }
    } catch (e) {
      print('Exception caught during HTTP request: $e');
      _showPopup('Error', 'An error occurred: $e');
    }
  }
//method to fetch events
  Future<void> _fetchMyEvents() async {
    String? userId = await getUserId();
    if (userId == null || userId.isEmpty) {
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
        print("Error response: ${response.statusCode} - ${response.body}");
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
      return prefs.getString('_id'); // Return null if not found
    } catch (e) {
      print('Failed to fetch user ID: $e');
      return null; // Return null to indicate failure
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
        title: const Text("Events", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
          TabBar(
            controller: _tabController,
            indicatorColor: CricketClubTheme().maincolor,
            labelColor: CricketClubTheme().maincolor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Upcoming Events'),
              Tab(text: 'My Events'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventList(_filteredUpcomingEvents),
                _buildEventList(_filteredMyEvents),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(List<Event> events) {
    if (events.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    Map<String, List<Event>> groupedEvents = {};
    for (var event in events) {
      String formattedDate = _formatDate(event.matchDate);
      if (groupedEvents.containsKey(formattedDate)) {
        groupedEvents[formattedDate]!.add(event);
      } else {
        groupedEvents[formattedDate] = [event];
      }
    }

    return ListView.builder(
      itemCount: groupedEvents.length,
      itemBuilder: (context, index) {
        String date = groupedEvents.keys.elementAt(index);
        List<Event> eventsOnThisDate = groupedEvents[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                date,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CricketClubTheme().maincolor),
              ),
            ),
            ...eventsOnThisDate.map((event) => _buildEventCard(event)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return FutureBuilder<String?>(
      future: getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Error retrieving user ID.'));
        } else {
          String userId = snapshot.data!;
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
                print("this is the stst ${event.playerStats}");
                print("this is the stst ${event.playerStats}");
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
                      userId: userId,
                      playerStats: event.playerStats,
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
