import 'dart:convert';
import 'package:cricket_club_fyp/configurations/config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cricket_club_fyp/constants/const_exports.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  ProfileEditScreen({required this.userData});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _countryController;
  late TextEditingController _categoryController;
  late TextEditingController _affiliatedOrgController;

  final List<String> _organizations = [];
  final TextEditingController _organizationController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with user data
    _nameController = TextEditingController(text: widget.userData['name'] ?? '');
    _dobController = TextEditingController(
        text: widget.userData['dateOfBirth'] != null
            ? _formatDate(widget.userData['dateOfBirth'])
            : '');
    _genderController = TextEditingController(text: widget.userData['gender'] ?? '');
    _contactController = TextEditingController(text: widget.userData['contactNumber'] ?? '');
    _addressController = TextEditingController(text: widget.userData['address'] ?? '');
    _countryController = TextEditingController(text: widget.userData['country'] ?? '');
    _categoryController = TextEditingController(text: widget.userData['category'] ?? '');
    _affiliatedOrgController = TextEditingController();

    if (widget.userData['affiliatedOrganizations'] != null) {
      _organizations.addAll(List<String>.from(widget.userData['affiliatedOrganizations']));
    }
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _categoryController.dispose();
    _affiliatedOrgController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  // Format date to 'yyyy-MM-dd'
  String _formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: CricketClubTheme().eeriesturquoise,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Email', widget.userData['email'], false), // Non-editable
              _buildTextField('Password', '**********', false), // Non-editable
              _buildTextField('Name', _nameController.text, true, _nameController),
              _buildTextField('Date of Birth', _dobController.text, true, _dobController),
              _buildTextField('Gender', _genderController.text, true, _genderController),
              _buildTextField('Contact Number', _contactController.text, true, _contactController),
              _buildTextField('Address', _addressController.text, true, _addressController),
              _buildTextField('Country', _countryController.text, true, _countryController),
              _buildTextField('Category', _categoryController.text, true, _categoryController),

              const SizedBox(height: 16),
              TextFormField(
                controller: _organizationController,
                decoration: const InputDecoration(
                  labelText: 'Add Organization',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_organizationController.text.isNotEmpty) {
                    setState(() {
                      _organizations.add(_organizationController.text);
                      _organizationController.clear();
                    });
                  }
                },
                child: const Text('Add Organization'),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _organizations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _organizations[index],
                      style: const TextStyle(color: Colors.black),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _organizations.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveProfileDetails();
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: CricketClubTheme().eeriesturquoise,
                    minimumSize: const Size(200, 48),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, bool editable, [TextEditingController? controller]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? value : null,
        enabled: editable,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
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

  Future<void> storeUserId(String userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('_id', userId);
      print('User ID $userId has been saved successfully.');
    } catch (e) {
      print('Failed to store user ID: $e');
    }
  }
  Future<void> _saveProfileDetails() async {
    String? userId = await getUserId();

    // Join the organizations list into a single string separated by commas
    String affiliatedOrgsString = _organizations.join(', ');

    Map<String, dynamic> updatedData = {
      'name': _nameController.text,
      'dateOfBirth': _dobController.text,
      'gender': _genderController.text,
      'contactNumber': _contactController.text,
      'address': _addressController.text,
      'country': _countryController.text,
      'category': _categoryController.text,
      'affiliatedOrganizations': affiliatedOrgsString,  // Send as a single string
    };

    // Log the updated data to see what is being sent
    print('Updated Data: ${jsonEncode(updatedData)}');

    try {
      final response = await http.put(
        Uri.parse('$updateprofile$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      // Log the response status and body
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Profile updated successfully: $responseData');
        Navigator.of(context).pop(updatedData);
      } else {
        // Handle error responses
        print('Failed to update profile. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${response.reasonPhrase}')),
        );
      }
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }
}
