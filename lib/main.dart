import 'package:cricket_club_fyp/dashboard/player/home_player.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cricket_club_fyp/start-screens/login-signup.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    print('Loading token from SharedPreferences...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('token');
    print('Token retrieved: $storedToken');

    if (storedToken != null && !JwtDecoder.isExpired(storedToken)) {
      print('Token is valid.');
      setState(() {
        token = storedToken;
      });
    } else {
      print('Token is null or expired.');
      setState(() {
        token = null;
      });
    }

    setState(() {
      isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      print('App is loading...');
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    print('App loaded. Token is ${token != null ? "valid" : "invalid"}.');
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/jouneyScreen': (context) => const Journey(),
      },
      debugShowCheckedModeBanner: false,
      home: token != null
          ? PlayerHome(token: token, logout: _logout)
          : const Journey(),
    );
  }
}
