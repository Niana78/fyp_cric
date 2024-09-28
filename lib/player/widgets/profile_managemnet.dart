import 'dart:convert';
import 'dart:io';
import 'package:cricket_club_fyp/configurations/config.dart';
import 'package:cricket_club_fyp/player/widgets/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/color_theme.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;
  String _profilePictureUrl = 'assets/images/main_logo.png';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
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

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat.yMMMd().format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<void> _fetchUserDetails() async {
    String? userId = await getUserId();

    if (userId == null) {
      print('User ID not found, cannot fetch user details');
      return;
    }

    try {
      final response = await http.get(Uri.parse('$getuserdetails$userId'));

      print("Server response status: ${response.statusCode}");
      print("Server response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == true && data.containsKey('user')) {
          final user = data['user'];

          // Correct key name for profile picture URL
          final String? profilePictureUrl = user['profilePictureUrl'];
          print("Profile Picture URL: $profilePictureUrl");

          // Prepend base URL to the path if necessary
          final String fullProfilePictureUrl = profilePictureUrl != null
              ? '$baseurl$profilePictureUrl'.replaceAll('\\', '/')
              : _profilePictureUrl;

          setState(() {
            _userData = user;
            _isLoading = false;
            _profilePictureUrl = fullProfilePictureUrl;
          });

          if (userId != user['_id']) {
            await storeUserId(user['_id']);
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

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        String? userId = await getUserId();
        if (userId == null) {
          print('User ID not found, cannot upload image');
          return;
        }

        var request = http.MultipartRequest(
          'POST',
          Uri.parse(uploadProfilePicture),
        );
        request.fields['userId'] = userId;

        request.files.add(await http.MultipartFile.fromPath('profilePicture', image.path));

        final response = await request.send();

        if (response.statusCode == 200) {
          final resData = await response.stream.bytesToString();
          final Map<String, dynamic> resMap = jsonDecode(resData);

          if (resMap['success']) {
            setState(() {
              _profilePictureUrl = resMap['imageUrl'];
            });
            print('Profile picture updated successfully.');
          } else {
            print('Failed to update profile picture.');
          }
        } else {
          print('Failed to upload image. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Management',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: CricketClubTheme().eeriesturquoise,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfileEditScreen(userData: _userData)),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4), // Space between text and icon
                  Icon(Icons.edit, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profilePictureUrl.startsWith('assets')
                          ? AssetImage(_profilePictureUrl)
                          : NetworkImage(Uri.encodeFull(_profilePictureUrl)) as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildProfileInfoField('Name', _userData['name'] ?? 'N/A'),
              _buildProfileInfoField(
                  'Email', _userData['email'] ?? 'N/A'),
              _buildProfileInfoField('Password', '**********'),
              _buildProfileInfoField('Date of Birth',
                  _formatDate(_userData['dateOfBirth']) ?? 'N/A'),
              _buildProfileInfoField(
                  'Gender', _userData['gender'] ?? 'N/A'),
              _buildProfileInfoField(
                  'Contact Number', _userData['contactNumber'] ?? 'N/A'),
              _buildDocumentSection(
                  'CNIC Front',
                  _userData['cnicFront'] ??
                      'assets/default_cnic_front.png'),
              _buildDocumentSection(
                  'CNIC Back',
                  _userData['cnicBack'] ??
                      'assets/default_cnic_back.png'),
              _buildProfileInfoField(
                  'Address', _userData['address'] ?? 'N/A'),
              _buildProfileInfoField(
                  'Country', _userData['country'] ?? 'N/A'),
              _buildProfileInfoField(
                  'Category', _userData['category'] ?? 'N/A'),
              _buildExpDocumentSection(
                  'Experience Document',
                  _userData['experienceDoc'] ??
                      'assets/default_experience_doc.pdf'),
              const SizedBox(height: 24),
              _buildAffiliatedOrganizations(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const Divider(color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(String label, String path) {
    String baseUrl = baseurl;
    String fullPath = path.replaceAll('\\', '/');
    String fullUrl = '$baseUrl$fullPath';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
              image: DecorationImage(
                image: NetworkImage(fullUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpDocumentSection(String label, String path) {
    String baseUrl = baseurl;
    String fullPath = path.replaceAll('\\', '/');
    String fullUrl = '$baseUrl$fullPath';
    String fileName = fullPath.split('/').last;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PDFScreen(url: fullUrl),
                ),
              );
            },
            child: Text(
              fileName,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.teal,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAffiliatedOrganizations() {
    if (_userData['affiliatedOrganizations'] != null) {
      try {
        List<String> organizations =
        List<String>.from(_userData['affiliatedOrganizations']);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Affiliated Organizations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              ...organizations.map((org) => Card(
                color: Colors.teal[50],
                child: ListTile(
                  leading: const Icon(Icons.business, color: Colors.teal),
                  title: Text(org),
                ),
              )),
            ],
          ),
        );
      } catch (e) {
        print('Error parsing affiliated organizations: $e');
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }
}

class PDFScreen extends StatelessWidget {
  final String url;

  PDFScreen({required this.url});

  Future<String> downloadAndSavePDF() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/temp.pdf');
        await file.writeAsBytes(bytes);

        print('PDF saved at: ${file.path}');
        return file.path;
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PDF Viewer",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: CricketClubTheme().eeriesturquoise,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<String>(
        future: downloadAndSavePDF(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return PDFView(
                filePath: snapshot.data,
              );
            } else {
              return Center(child: Text('Failed to load PDF'));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
