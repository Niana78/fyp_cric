import 'package:cricket_club_fyp/configurations/config.dart';
import 'package:cricket_club_fyp/constants/const_exports.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../constants/custom_textfields.dart';
import 'package:http/http.dart' as http;

import '../../constants/custom_textfirld_address.dart';


class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  CreateMatchScreenState createState() => CreateMatchScreenState();
}

class CreateMatchScreenState extends State<CreateMatchScreen> {
  final TextEditingController matchNameController = TextEditingController();
  final TextEditingController hostNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String notesfromhost = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<dynamic> _placeList = [];
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final Color customColor3 = const Color(0xFF088395);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CustomButton(
              text: 'Submit',
              color: CricketClubTheme().eeriesturquoise,
              onPressed: _submitForm,
              width: 200,
              height: 40,
            ),
          )
        ],
        title: Text(
          "Cancel",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: customColor3,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Material(
            elevation: 4,
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: 37,
              height: 37,
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: customColor3,
              ),
            ),
          ),
        ),
      ),      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Match',
                  style: CricketTextTheme().heading1.copyWith(
                    fontWeight: FontWeight.w800,
                    color: CricketClubTheme().eeriesturquoise,
                  ),
                ),
                SizedBoxes.vertical15Px,
                Text(
                  ' Your Match will be OTP',
                  style: CricketTextTheme().headline.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CricketClubTheme().black,
                  ),
                ),
                SizedBoxes.verticalMicro,
                Text(
                  ' Open to Public',
                  style: CricketTextTheme().small.copyWith(
                    fontWeight: FontWeight.w500,
                    color:CricketClubTheme().eeriesturquoise,
                  ),
                ),
                SizedBoxes.vertical26Px,
                Text(
                  'Host Name*',
                  style: CricketTextTheme().heading6.copyWith(
                    fontWeight: FontWeight.w800,
                    color: CricketClubTheme().eeriesturquoise,
                  ),
                ),
                SizedBoxes.vertical10Px,
                CustomTextField(
                  controller: hostNameController,
                  prefixIcon: Icon(Icons.person_pin_sharp,
                      color: CricketClubTheme().maincolor),
                  hintText: "Host Name",
                  hintStyle: TextStyle(color: CricketClubTheme().maincolor),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Host name is required'
                      : null,
                ),
                SizedBoxes.vertical26Px,
                Text(
                  'Match Name*',
                  style: CricketTextTheme().heading6.copyWith(
                    fontWeight: FontWeight.w800,
                    color: CricketClubTheme().eeriesturquoise,
                  ),
                ),
                SizedBoxes.vertical10Px,
                CustomTextField(
                  controller: matchNameController,
                  prefixIcon: Icon(Icons.person_pin_sharp,
                      color: CricketClubTheme().maincolor),
                  hintText: "Match Name",
                  hintStyle: TextStyle(color: CricketClubTheme().maincolor),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Match name is required'
                      : null,
                ),
                SizedBoxes.vertical26Px,
                Text(
                  'Date & Time*',
                  style: CricketTextTheme().heading6.copyWith(
                    fontWeight: FontWeight.w800,
                    color: CricketClubTheme().eeriesturquoise,
                  ),
                ),
                SizedBoxes.vertical10Px,
                Row(
                  children: [
                    Card(
                      elevation: 5,
                      child: Container(
                        height: 42,
                        width: 150,
                        decoration: BoxDecoration(
                          color: CricketClubTheme().white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: _pickDate,
                                child: Icon(
                                  Icons.calendar_month_outlined,
                                  color: CricketClubTheme().maincolor,
                                ),
                              ),
                              SizedBoxes.horizontalMedium,
                              Expanded(
                                child: IgnorePointer(
                                  child: TextFormField(
                                    controller: dateController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Select Date',
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        color: CricketClubTheme().maincolor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      child: Container(
                        height: 42,
                        width: 142,
                        decoration: BoxDecoration(
                          color: CricketClubTheme().white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: _pickTime,
                                child: Icon(
                                  Icons.access_time_outlined,
                                  color: CricketClubTheme().maincolor,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8, top: 5),
                                  child: IgnorePointer(
                                    child: TextFormField(
                                      controller: timeController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Select Time',
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          color:CricketClubTheme().maincolor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBoxes.vertical26Px,
                Text(
                  'Address',
                  style: CricketTextTheme().heading6.copyWith(
                    color: CricketClubTheme().eeriesturquoise,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBoxes.vertical10Px,
                Text(
                  'Write the full address of the location, or pinpoint the location from the map.',
                  style: CricketTextTheme().heading7.copyWith(
                    fontWeight: FontWeight.w500,
                    color: CricketClubTheme().maincolor,
                  ),
                ),
                SizedBoxes.verticalBig,
                CustomTextField1(
                  controller: addressController,
                  prefixIcon:
                  Icon(Icons.location_pin, color: CricketClubTheme().maincolor),
                  hintText: "Complete Address",
                  hintStyle:  TextStyle(
                      color: CricketClubTheme().maincolor, fontWeight: FontWeight.w400),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Address is required'
                      : null,
                  suggestions: _placeList
                      .map((place) => place['description'] as String)
                      .toList(),
                  onSuggestionSelected: (selectedSuggestion) {
                    addressController.text = selectedSuggestion;
                    _onChanged();
                  },
                ),
                SizedBoxes.vertical26Px,
                Text(
                  'Notes from Host',
                  style: CricketTextTheme().heading6.copyWith(
                    color: CricketClubTheme().eeriesturquoise,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBoxes.vertical10Px,
                TextField(
                  onChanged: (value) {
                   notesfromhost = value;
                  },
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write the notes...',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: CricketClubTheme().eeriesturquoise,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: CricketClubTheme().eeriesturquoise,
                        width: 2.0,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: CricketClubTheme().eeriesturquoise,
                        width: 2.0,
                      ),
                    ),
                  ),
                )

              ],
            ),
          ),
        )),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text = "${selectedDate!.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
        final int hour = pickedTime.hour;
        final int minute = pickedTime.minute;
        timeController.text = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      });
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



  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed.");
      return;
    }

    if (matchNameController.text.isEmpty ||
        hostNameController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        addressController.text.isEmpty) {
      print("Some required fields are empty.");
      _showPopup('Error', 'Please fill in all required fields.');
      return;
    }

    String? userId = await getUserId();
    if (userId == null) {
      print("User ID not found in SharedPreferences.");
      _showPopup('Error', 'Failed to retrieve user ID. Please log in again.');
      return;
    }

    print("Form values before submission:");
    print("Match Name: ${matchNameController.text}");
    print("Host Name: ${hostNameController.text}");
    print("Match Date: ${dateController.text}");
    print("Match Time: ${timeController.text}");
    print("Match Location: ${addressController.text}");
    print("Notes: $notesfromhost");

    final body = jsonEncode({
      'hostName': hostNameController.text,
      'matchName': matchNameController.text,
      'matchDate': dateController.text,
      'matchTime': timeController.text,
      'matchLocation': addressController.text,
      'notes': notesfromhost,
      'totalPlayers': '12',
      'createdBy': userId,
    });

    try {
      final response = await http.post(
        Uri.parse(creatematch),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201) {
        _showPopup('Success', 'Match created successfully.');
      } else if (response.statusCode == 400) {
        _showPopup('Error', 'There was a problem with your request. Please check the input fields.');
      } else if (response.statusCode == 500) {
        _showPopup('Server Error', 'An error occurred on the server. Please try again later.');
      } else {
        _showPopup('Error', 'An unexpected error occurred. Please try again.');
      }
    } catch (e) {
      print("Exception caught during HTTP request: $e");
      _showPopup('Error', 'An error occurred: $e');
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

  _onChanged() {
    // ignore: unnecessary_null_comparison
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(addressController.text);
  }

  void getSuggestion(String input) async {
    const String PLACES_API_KEY = "AIzaSyDO2VyNH8vC2ZhZX8BhwpkvzxKaSLAE0ic";

    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$PLACES_API_KEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (kDebugMode) {
        print('mydata');
        print(data);
      }
      if (response.statusCode == 200) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

}
