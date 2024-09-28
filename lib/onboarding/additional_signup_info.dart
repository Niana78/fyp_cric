import 'dart:convert';
import 'dart:io';
import 'package:cricket_club_fyp/dashboard/player/home_player.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../configurations/config.dart';
import '../start-screens/login-signup.dart';
import 'otp-verification/otp_verif_player.dart';

class OptionalOnboarding extends StatefulWidget {
  const OptionalOnboarding({
    Key? key,
    required this.name,
    required this.dob,
    required this.email,
    required this.password,
    required this.gender,
    required this.contactNumber,
  }) : super(key: key);

  final String name;
  final String dob;
  final String email;
  final String password;
  final String? gender;
  final String contactNumber;

  @override
  State<OptionalOnboarding> createState() => _OptionalOnboardingState();
}

class _OptionalOnboardingState extends State<OptionalOnboarding> {
  Color customColor1 = const Color(0xff0F2630);
  Color customColor3 = const Color(0xFF088395);
  String? _country;
  String? _category;
  final _formKey = GlobalKey<FormState>();
  String? token;
  final List<String> _organizations = [];
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  XFile? _cnicFrontImage;
  XFile? _cnicBackImage;
  PlatformFile? _experienceDoc;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickCnicFrontImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _cnicFrontImage = pickedImage;
      });
    }
  }

  Future<void> _pickCnicBackImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _cnicBackImage = pickedImage;
      });
    }
  }

  Future<void> _pickExperienceDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _experienceDoc = result.files.first;
      });
    }
  }

  void signUpUser() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var reqBody = {
        "name": widget.name,
        "email": widget.email,
        "password": widget.password,
        "dateOfBirth": widget.dob,
        "gender": widget.gender ?? '',
        "contactNumber": widget.contactNumber,
        "address": _addressController.text,
        "country": _country ?? '',
        "category": _category ?? '',
        "affiliatedOrganizations": _organizations,
      };

      var request = http.MultipartRequest('POST', Uri.parse(registration))
        ..fields.addAll(reqBody.map((key, value) => MapEntry(key, value is List ? jsonEncode(value) : value.toString())))
        ..headers.addAll({"Content-Type": "application/json"});

      if (_cnicFrontImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'cnicFront',
          _cnicFrontImage!.path,
          contentType: http_parser.MediaType('image', 'jpeg'),
        ));
      }

      if (_cnicBackImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'cnicBack',
          _cnicBackImage!.path,
          contentType: http_parser.MediaType('image', 'jpeg'),
        ));
      }

      if (_experienceDoc != null) {
        request.files.add(http.MultipartFile(
          'experienceDoc',
          File(_experienceDoc!.path!).readAsBytes().asStream(),
          File(_experienceDoc!.path!).lengthSync(),
          filename: _experienceDoc!.name,
          contentType: http_parser.MediaType('application', 'octet-stream'),
        ));
      }

      var response = await request.send();

      print("Request URL: $registration");
      print("Request Body: $reqBody");
      print("Response Status Code: ${response.statusCode}");
      var responseBody = await response.stream.bytesToString();
      print("Response Body: $responseBody");

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(responseBody);

        var userId = jsonResponse['user']['_id'];
        var email = jsonResponse['user']['email'];

        await storeUserId(userId, email);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User registered successfully!")),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EmailVerification(email: widget.email,
          ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to register user: ${response.reasonPhrase}")),
        );
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> storeUserId(String userId, String email) async {
    try {
      // Debugging print to verify function is being called
      print('Attempting to store user ID: $userId');

      SharedPreferences prefs = await SharedPreferences.getInstance();

      print('SharedPreferences initialized.');

      await prefs.setString('_id', userId);
      await prefs.setString('email', email);
      String? storedId = prefs.getString('_id');
      String? storedemail = prefs.getString('email');
      if (storedId == userId && storedemail == email) {
        print('User ID $userId has been saved successfully and $email too.');
      } else {
        print('Failed to save User ID $userId.');
      }
    } catch (e) {
      print('Failed to store user ID: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customColor1,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 70),
                const Center(
                  child: Text(
                    "Continue Your Sign Up Process",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 24),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: customColor3, width: 6),
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white),
                  width: 400,
                  height: 600,
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          TextFormField(
                            // keyboardType: TextInputType.number,
                            controller: _cnicController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              labelText: 'CNIC',
                              labelStyle: TextStyle(color: Colors.black),
                              hintStyle: TextStyle(color: Colors.black),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 3.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2.0),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2.0),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text('CNIC Picture:', style: TextStyle(color: Colors.black)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: _pickCnicFrontImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: customColor3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  fixedSize: const Size(140, 40),
                                ),
                                child: const Text('Upload Front', style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _pickCnicBackImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: customColor3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  fixedSize: const Size(140, 40),
                                ),
                                child: const Text('Upload Back', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_cnicFrontImage != null)
                            Image.file(File(_cnicFrontImage!.path), height: 100),
                          if (_cnicBackImage != null)
                            Image.file(File(_cnicBackImage!.path), height: 100),
                          const SizedBox(height: 16),
                          TextFormField(
                            style: const TextStyle(color: Colors.black),
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              labelStyle: TextStyle(color: Colors.black),
                              hintStyle: TextStyle(color: Colors.black),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2.0),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2.0),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Country',
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2.0),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2.0),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2.0),
                              ),
                            ),
                            value: _country,
                            onChanged: (String? newValue) {
                              setState(() {
                                _country = newValue;
                              });
                            },
                            items: <String>[
                              'Pakistan',
                              'Afghanistan',
                              'Kashmir'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    value,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              );
                            }).toList(),
                            selectedItemBuilder: (BuildContext context) {
                              return <String>[
                                'Pakistan',
                                'Afghanistan',
                                'Kashmir'
                              ].map<Widget>((String value) {
                                return Text(
                                  value,
                                  style: const TextStyle(color: Colors.black),
                                );
                              }).toList();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field cannot be empty';
                              }
                              return null;
                            },
                            dropdownColor: customColor3,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2.0),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2.0),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2.0),
                              ),
                            ),
                            value: _category,
                            onChanged: (String? newValue) {
                              setState(() {
                                _category = newValue;
                              });
                            },
                            items: <String>[
                              'Under 13',
                              'Under 15',
                              'Under 19',
                              'Above 19'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    value,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              );
                            }).toList(),
                            selectedItemBuilder: (BuildContext context) {
                              return <String>[
                                'Under 13',
                                'Under 15',
                                'Under 19',
                                'Above 19'
                              ].map<Widget>((String value) {
                                return Text(
                                  value,
                                  style: const TextStyle(color: Colors.black),
                                );
                              }).toList();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field cannot be empty';
                              }
                              return null;
                            },
                            dropdownColor: customColor3,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Experience Document:',
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _pickExperienceDocument,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: customColor3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              fixedSize: const Size(100, 40),
                            ),
                            child: const Text(
                              'Upload Document',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_experienceDoc != null)
                            Text(
                              'Document Selected: ${_experienceDoc!.name}',
                              style: const TextStyle(color: Colors.black),
                            ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _organizationController,
                            decoration: const InputDecoration(
                              labelText: 'Add Organization',
                              labelStyle: TextStyle(color: Colors.black),
                              hintStyle: TextStyle(color: Colors.black),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2.0),
                              ),
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
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : signUpUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: customColor3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              fixedSize: const Size(200, 50),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              'Sign Up',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _logout(BuildContext context) async {
    print('Logging out...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('Token removed from SharedPreferences.');

    setState(() {
      token = null;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Journey()),
    );
  }

}
