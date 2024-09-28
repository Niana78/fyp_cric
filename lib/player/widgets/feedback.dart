import 'package:cricket_club_fyp/constants/const_exports.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:shared_preferences/shared_preferences.dart';

import '../../configurations/config.dart';

class HelpandSupport extends StatefulWidget {
  const HelpandSupport({Key? key}) : super(key: key);

  @override
  _HelpandSupportState createState() => _HelpandSupportState();
}

class _HelpandSupportState extends State<HelpandSupport> {
  TextEditingController descriptionController = TextEditingController();
  PickedFile? _pickedImage;

  Future<void> _pickImage() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = pickedImage != null ? PickedFile(pickedImage.path) : null;
    });
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> submitIssue(String description, String? imagePath) async {
    try {
      String? userEmail = await getUserEmail();

      print("this is the user email fetched $userEmail");

      final apiUrl = Uri.parse('$issuesubmit');
      final request = http.MultipartRequest('POST', apiUrl);

      request.fields['description'] = description;
      if (userEmail != null) {
        request.fields['userEmail'] = userEmail;
      }

      if (imagePath != null) {
        final imageFile = File(imagePath);
        final contentType = imageFile.path.toLowerCase().endsWith('.jpg') ||
            imageFile.path.toLowerCase().endsWith('.jpeg')
            ? 'image/jpeg'
            : imageFile.path.toLowerCase().endsWith('.png')
            ? 'image/png'
            : 'application/octet-stream';

        request.files.add(await http.MultipartFile.fromPath(
          'screenshot',
          imageFile.path,
          contentType: http_parser.MediaType.parse(contentType),
        ));
      }

      print('Request URL: ${request.url}');
      print('Request headers: ${request.headers}');
      print('Request fields: ${request.fields}');
      print(
          'Request files: ${request.files.map((file) => file.filename)}');

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _showSuccessDialog(responseData['message']);
      } else {
        _showErrorDialog('Failed to submit issue. Please try again later.');
      }
    } catch (error) {
      _showErrorDialog('An error occurred: $error');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success', style: TextStyle(color: Colors.green)),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error', style: TextStyle(color: Colors.red)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Support and Feedback',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: CricketClubTheme().eeriesturquoise,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: CricketClubTheme().maincolor,
                  ),
                  SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      "If you have encountered any issues or have feedback regarding the app, please describe it below. You can also attach a screenshot to help us understand the issue better.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Feedback or Issue',
                  labelStyle: TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Attach Screenshot'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CricketClubTheme().maincolor,
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await submitIssue(
                        descriptionController.text, _pickedImage?.path);
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Send Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CricketClubTheme().maincolor,
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
}
