import 'package:cricket_club_fyp/configurations/config.dart';
import 'package:cricket_club_fyp/constants/const_exports.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../constants/custom_textfields.dart';

class ScheduleMatchScreen extends StatefulWidget {
  const ScheduleMatchScreen({super.key});

  @override
  ScheduleMatchScreenState createState() => ScheduleMatchScreenState();

}

class ScheduleMatchScreenState extends State<ScheduleMatchScreen> {
  final TextEditingController matchNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController scheduleTimeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String notesfromhost = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? scheduledDateTime;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
              text: 'Schedule',
              color: CricketClubTheme().eeriesturquoise,
              onPressed: _confirmSchedule,
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule Match',
                  style: CricketTextTheme().heading1.copyWith(
                    fontWeight: FontWeight.w800,
                    color: CricketClubTheme().eeriesturquoise,
                  ),
                ),
                SizedBoxes.vertical15Px,
                Text(
                  'Your Match will be OTP',
                  style: CricketTextTheme().headline.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CricketClubTheme().black,
                  ),
                ),
                SizedBoxes.verticalMicro,
                Text(
                  'Open to Public',
                  style: CricketTextTheme().small.copyWith(
                    fontWeight: FontWeight.w500,
                    color: CricketClubTheme().eeriesturquoise,
                  ),
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
                                          color: CricketClubTheme().maincolor,
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
                  'Schedule Submission*',
                  style: CricketTextTheme().heading6.copyWith(
                    fontWeight: FontWeight.w800,
                    color: CricketClubTheme().eeriesturquoise,
                  ),
                ),
                SizedBoxes.vertical10Px,
                Card(
                  elevation: 5,
                  child: Container(
                    height: 42,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: CricketClubTheme().white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: _pickScheduleTime,
                            child: Icon(
                              Icons.schedule,
                              color: CricketClubTheme().maincolor,
                            ),
                          ),
                          SizedBoxes.horizontalMedium,
                          Expanded(
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: scheduleTimeController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Select Schedule Time',
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
                CustomTextField(
                  controller: addressController,
                  prefixIcon: Icon(Icons.location_pin,
                      color: CricketClubTheme().maincolor),
                  hintText: "Complete Address",
                  hintStyle: TextStyle(
                      color: CricketClubTheme().maincolor,
                      fontWeight: FontWeight.w400),
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
        ),
      ),
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

  Future<void> _pickScheduleTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          scheduledDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          scheduleTimeController.text =
          "${DateFormat.yMMMd().format(scheduledDateTime!)} ${pickedTime.format(context)}";
        });
      }
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

  void _confirmSchedule() {
    if (scheduledDateTime == null) {
      _showPopup('Error', 'Please select a schedule time.');
      return;
    }

    _showPopup(
      'Confirm Schedule',
      'Your match will be automatically submitted on ${DateFormat.yMMMd().format(scheduledDateTime!)} at ${TimeOfDay.fromDateTime(scheduledDateTime!).format(context)}.',
    );

    _scheduleSubmission();
  }

  void _scheduleSubmission() async {
    if (scheduledDateTime == null) {
      _showPopup('Error', 'Please select a schedule time.');
      return;
    }

    DateTime now = DateTime.now();
    Duration difference = scheduledDateTime!.difference(now);

    if (difference.isNegative) {
      _showPopup('Error', 'Scheduled time must be in the future.');
      return;
    }

    Future.delayed(difference, () async {
      if (mounted) {
        bool success = await _submitForm();
        if (success) {
        } else {
        }
      }
    });

    _showPopup('Success', 'Match has been scheduled successfully.');
  }


  Future<bool> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed.");
      return false;
    }

    if (matchNameController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        addressController.text.isEmpty) {
      print("Some required fields are empty.");
      _showPopup('Error', 'Please fill in all required fields.');
      return false;
    }

    String? userId = await getUserId();
    if (userId == null) {
      print("User ID not found in SharedPreferences.");
      _showPopup('Error', 'Failed to retrieve user ID. Please log in again.');
      return false;
    }

    // Additional logging for debugging
    print("User ID: $userId");
    print("Scheduled DateTime: $scheduledDateTime");
    print("Form values before submission:");
    print("Match Name: ${matchNameController.text}");
    print("Match Date: ${dateController.text}");
    print("Match Time: ${timeController.text}");
    print("Match Location: ${addressController.text}");
    print("Notes: $notesfromhost");

    final body = jsonEncode({
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

      // Logging the full response for debugging
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201) {
        _showPopup('Success', 'Match created successfully.');
        return true;
      } else if (response.statusCode == 400) {
        _showPopup('Error', 'There was a problem with your request. Please check the input fields.');
        return false;
      } else if (response.statusCode == 500) {
        _showPopup('Server Error', 'An error occurred on the server. Please try again later.');
        return false;
      } else {
        _showPopup('Error', 'An unexpected error occurred. Please try again.');
        return false;
      }
    } catch (e) {
      print("Exception caught during HTTP request: $e");
      _showPopup('Error', 'An error occurred: $e');
      return false;
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
}
