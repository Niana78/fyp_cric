import 'dart:convert';
import 'package:cricket_club_fyp/constants/const_exports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../configurations/config.dart';
import 'package:flutter/services.dart';

class SearchPlayersBottomSheet extends StatefulWidget {
  const SearchPlayersBottomSheet({
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
  State<SearchPlayersBottomSheet> createState() =>
      _SearchPlayersBottomSheetState();
}

class _SearchPlayersBottomSheetState extends State<SearchPlayersBottomSheet> {
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
  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat.yMMMd().format(date);
    } catch (e) {
      return 'Invalid Date';
    }
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
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendEmail(String receiverEmail, String playerName) async {
    final date = _formatDate(widget.matchDate ?? '');
    final String emailBody = '''
Dear Sir/Madam,

We are pleased to invite you to a Cricket Event that will take place at the following location:
Name: ${widget.name ?? ''}
Address: ${widget.location ?? ''}
Date: $date
Time: ${widget.matchTime ?? ''}
Host: ${widget.host ?? ''}

We hope to see you there.

Best regards,
Cricket Club
''';

    final Uri gmailUri = Uri(
      scheme: 'mailto',
      path: receiverEmail,
      query: 'subject=${Uri.encodeComponent('You\'re Invited to a Cricket Event!')}&body=${Uri.encodeComponent(emailBody)}',
    );

    final Uri gmailAppUri = Uri(
      scheme: 'googlegmail',
      path: '/co',
      queryParameters: {
        'to': receiverEmail,
        'subject': 'You\'re Invited to a Cricket Event!',
        'body': emailBody,
      },
    );

    try {
      if (await canLaunchUrl(gmailAppUri)) {
        await launchUrl(gmailAppUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(gmailUri)) {
        await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
      } else {
        throw PlatformException(code: 'EMAIL_CLIENT_NOT_AVAILABLE', message: 'No email client available');
      }
    } catch (e) {
      print('Error opening email client: $e');
    }
  }

  void _showInviteDialog(String playerName, String playerEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invite $playerName'),
          content: Text('Do you want to invite $playerName via email to join the match?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendEmail(playerEmail, playerName);
              },
              child: const Text('Yes'),
            ),
          ],
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
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
                final String profilePictureUrl = player['profilePictureUrl'] != null
                    ? baseImageUrl + player['profilePictureUrl']
                    : '';

                return ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      if (profilePictureUrl.isNotEmpty) {
                        showProfilePicture(context, profilePictureUrl, player['name']);
                      }
                    },
                    child: CircleAvatar(
                      backgroundImage: profilePictureUrl.isNotEmpty
                          ? NetworkImage(profilePictureUrl)
                          : null,
                      child: profilePictureUrl.isEmpty
                          ? Text(player['name'][0])
                          : null,
                    ),
                  ),
                  title: Text(player['name'] ?? 'Unknown'),
                  subtitle: Text(player['email'] ?? 'No Email'),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, color: CricketClubTheme().maincolor),
                  onTap: () {
                    // Show the invite dialog
                    _showInviteDialog(player['name'], player['email']);
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
