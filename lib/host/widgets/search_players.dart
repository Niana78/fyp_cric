import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cricket_club_fyp/configurations/config.dart';
import 'package:cricket_club_fyp/constants/color_theme.dart';
import 'view_other_user_profile.dart'; // Import the ViewOtherUserProfile screen

class SearchPlayers extends StatefulWidget {
  const SearchPlayers({
    super.key,
    this.name,
    this.location,
    this.totalPlayers,
    this.matchDate,
    this.matchTime,
    this.notes,
    this.createdBy,
    this.host,
  });

  final String? host;
  final String? name;
  final String? location;
  final int? totalPlayers;
  final String? matchDate;
  final String? matchTime;
  final String? notes;
  final String? createdBy;

  @override
  State<SearchPlayers> createState() => _SearchPlayersState();
}

class _SearchPlayersState extends State<SearchPlayers> {
  List<Map<String, dynamic>> players = [];
  String searchQuery = '';
  bool isLoading = true;
  String? _useremail;

  final String baseImageUrl = baseurl;

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  Future<void> fetchPlayers() async {
    try {
      final response = await http.get(Uri.parse(getusers));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
          setState(() {
            players = List<Map<String, dynamic>>.from(data['users']);
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load users');
        }
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching players: $error');
    }
  }

  void showProfilePicture(BuildContext context, String imageUrl, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(imageUrl),
                child: imageUrl.isEmpty ? Text(name[0]) : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlayers = players.where((player) {
      final playerName = (player['name'] ?? '').toString().toLowerCase();
      return playerName.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Search Players',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: CricketClubTheme().white,
          ),
        ),
        backgroundColor: CricketClubTheme().eeriesturquoise,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPlayers.length,
              itemBuilder: (context, index) {
                final player = filteredPlayers[index];

                final String profilePictureUrl =
                player['profilePictureUrl'] != null
                    ? baseImageUrl + player['profilePictureUrl']
                    : '';

                return ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      if (profilePictureUrl.isNotEmpty) {
                        showProfilePicture(
                            context, profilePictureUrl, player['name']);
                      }
                    },
                    child: CircleAvatar(
                      backgroundImage: profilePictureUrl.isNotEmpty
                          ? NetworkImage(profilePictureUrl)
                          : null,
                      child: profilePictureUrl.isEmpty
                          ? Text(player['name'][0])
                          : null, // Show first letter if no profile picture
                    ),
                  ),
                  title: Text(player['name'] ?? 'Unknown'),
                  subtitle: Text(player['email'] ?? 'No Email'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to ViewOtherUserProfile screen with userId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewOtherUserProfile(
                          userId: player['_id'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
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

  void _fetchUserEmail() async {
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
            _useremail = user['email'];
          });
          print("User name set to: $_useremail");

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
}
