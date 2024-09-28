import 'package:cricket_club_fyp/notifications.dart';
import 'package:cricket_club_fyp/player/widgets/profile_managemnet.dart';
import 'package:cricket_club_fyp/settings/delete_acc.dart';
import 'package:cricket_club_fyp/settings/faqs.dart';
import 'package:cricket_club_fyp/settings/privacy.dart';
import 'package:cricket_club_fyp/settings/term_of_services.dart';
import 'package:cricket_club_fyp/settings/version_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../change_password/change_password.dart';
import '../configurations/config.dart';
import '../player/widgets/feedback.dart';
import '../player/widgets/upcoming_events.dart';
import '../start-screens/login-signup.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Color customColor1 = const Color(0xff0F2630);
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  bool _isDarkMode = false;
  int _selectedIndex = 0;
  final Color customColor3 = const Color(0xFF088395);



  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  void _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
      prefs.setBool('isDarkMode', value);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pop(context);
        break;
      case 1:
      // Navigate to Settings
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingScreen()),  // Replace with your actual Settings screen widget
        );
        break;
      case 2:
      // Navigate to Events
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UpcomingEventsScreen()),
        );
        break;
      case 3:
      // Navigate to Notifications
      // Add your navigation logic here for notifications
        break;
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(login),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logging out')),
        );
        print('Logging out');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Journey()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logging out')),
        );
        print('Error logging out');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => Journey()),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logging out')),
      );
      print('Error logging out: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: _isDarkMode ? Colors.white : Colors.black,
            onPressed: () {
              Navigator.of(context).pop(
              );
            },
          ),
          title: Text(
            'Settings',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              color: _isDarkMode ? Colors.white : Colors.black, // Change color based on dark mode
              onPressed: () {
                showSearch(context: context, delegate: SettingSearchDelegate());
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildSection('Account', [
                _buildSetting('My Account', Icons.account_circle, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                         ProfileManagementScreen(),
                    ),
                  );
                },),
                _buildSetting('Privacy and Security', Icons.security,onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PrivacyPolicyScreen(),
                    ),
                  );
                }),
              ]),
              _buildDivider(),
              _buildSection('General', [
                _buildSetting('Notifications', Icons.notifications, onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Notifications(),
                    ),
                  );
                }),
                _buildSetting('Account Deletion', Icons.delete_forever_outlined,onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DeleteAccount()),
                  );
                }),
                _buildDarkModeSetting(),
                _buildSetting('Change Password', Icons.remove_red_eye, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                  );
                }),
              ]),
              _buildDivider(),
              _buildSection('About', [
                _buildSetting('Terms and Services', Icons.description, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TermsOfServiceScreen()),
                  );
                }),
                _buildSetting('Help and Support', Icons.help, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpandSupport()),
                  );
                }),
                _buildSetting('FAQs', Icons.question_answer, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FaqScreen()),
                  );
                }),
              ]),
              _buildDivider(),
              _buildSection('Other', [
                _buildSetting('Version and Update', Icons.system_update, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VersionUpdateScreen()),
                  );
                }),
                _buildSetting('Logout', Icons.exit_to_app, onTap: () {
                  _logout(context);

                },),
              ]),
            ],
          ),
        ),
        // bottomNavigationBar: BottomNavigationBar(
        //   items: const <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.home),
        //       label: 'Home',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.settings),
        //       label: 'Settings',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.event),
        //       label: 'Events',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.notifications),
        //       label: 'Notifications',
        //     ),
        //   ],
        //   currentIndex: _selectedIndex,
        //   selectedItemColor: customColor3,
        //   unselectedItemColor: Colors.grey,
        //   onTap: _onItemTapped,
        //   iconSize: 30.0,
        // ),

      ),
    );
  }

  Widget _buildSection(String title, List<Widget> settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...settings,
      ],
    );
  }

  Widget _buildSetting(String title, IconData icon, {Function()? onTap}) {
    if (_searchText.isNotEmpty && !title.toLowerCase().contains(_searchText.toLowerCase())) {
      return Container();
    }
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap,
    );
  }

  Widget _buildDarkModeSetting() {
    return ListTile(
      title: Text('Dark Mode'),
      leading: Icon(Icons.dark_mode),
      trailing: Switch(
        value: _isDarkMode,
        onChanged: _toggleDarkMode,
      ),
    );
  }


  Widget _buildDivider() {
    return const Divider(
      height: 16,
      thickness: 1,
      color: Colors.grey,
    );
  }
}

class SettingSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> settings = [
    {'title': 'My Account', 'icon': Icons.account_circle, 'widget': ProfileManagementScreen()},
    {'title': 'Privacy and Security', 'icon': Icons.security, 'widget':PrivacyPolicyScreen()},
    {'title': 'Payments', 'icon': Icons.payment, 'widget': null},
    {'title': 'Notifications', 'icon': Icons.notifications, 'widget': Notifications()},
    {'title': 'Account Deletion', 'icon': Icons.delete_forever_outlined, 'widget': DeleteAccount()},
    {'title': 'Dark Mode', 'icon': Icons.dark_mode, 'widget': null},
    {'title': 'Change Password', 'icon': Icons.remove_red_eye, 'widget': ChangePasswordScreen()},
    {'title': 'Terms and Services', 'icon': Icons.description, 'widget': TermsOfServiceScreen()},
    {'title': 'Help and Support', 'icon': Icons.help, 'widget': HelpandSupport()},
    {'title': 'FAQs', 'icon': Icons.question_answer, 'widget': FaqScreen()},
    {'title': 'Version and Update', 'icon': Icons.system_update, 'widget': null},
    {'title': 'Logout', 'icon': Icons.exit_to_app, 'widget': null},
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = settings.where((setting) => setting['title'].toLowerCase().contains(query.toLowerCase()));

    return ListView(
      children: results.map<Widget>((setting) {
        return ListTile(
          title: Text(setting['title']),
          leading: Icon(setting['icon']),
          onTap: () {
            if (setting['widget'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => setting['widget']),
              );
            }
          },
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = settings.where((setting) => setting['title'].toLowerCase().contains(query.toLowerCase()));

    return ListView(
      children: suggestions.map<Widget>((setting) {
        return ListTile(
          title: Text(setting['title']),
          leading: Icon(setting['icon']),
          onTap: () {
            if (setting['widget'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => setting['widget']),
              );
            }
          },
        );
      }).toList(),
    );
  }
  Future<void> sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'majlisnearbyofficial@gmail.com',
      queryParameters: {'subject': 'Support Request', 'body': 'Hi,'},
    );

    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      throw 'Could not launch email client';
    }
  }
}
