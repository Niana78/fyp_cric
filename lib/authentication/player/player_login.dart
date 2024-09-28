import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../change_password/forgot_password.dart';
import '../../configurations/config.dart';
import '../../dashboard/player/home_player.dart';

class PlayerLoginScreen extends StatefulWidget {
  const PlayerLoginScreen({super.key});

  @override
  State<PlayerLoginScreen> createState() => _PlayerLoginScreenState();
}

class _PlayerLoginScreenState extends State<PlayerLoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Color customColor1 = const Color(0xff0F2630);
  Color customColor2 = const Color(0xff0F2630);
  Color customColor3 = const Color(0xFF088395);
  bool _isPasswordVisible = false;


  void loginUser() async {
    try {
      if (_emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty) {
        var reqBody = {
          "email": _emailController.text,
          "password": _passwordController.text
        };

        var response = await http.post(Uri.parse(login),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(reqBody));
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);

          if (jsonResponse.containsKey('status')) {
            if (jsonResponse['status']) {
              var myToken = jsonResponse['token'];

              Map<String, dynamic> decodedToken = JwtDecoder.decode(myToken);
              var userId = decodedToken['_id'];
              var email = decodedToken['email'];
              await storeUserId(userId, email);

              if (userId != null) {

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PlayerHome()));
              } else {
                throw Exception("User ID not found in token");
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Invalid email or password. Please try again."),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Unexpected response from server"),
              ),
            );
          }
        } else {
          print("HTTP request failed with status code: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("HTTP request failed. Please try again."),
            ),
          );
        }
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Wrong email or password. Please try again."),
        ),
      );
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
        key: _scaffoldKey,
        backgroundColor: customColor1,
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  "Welcome Back!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Enter your details',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextFormField(

                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.white, width: 3.0),
                          ),
                          focusedBorder:  UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.white, width: 3.0),
                          ),
                          errorBorder:  UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.red, width: 3.0),
                          ),
                          focusedErrorBorder:UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.red, width: 3.0),
                          ),

                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          RegExp regex =
                              RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                          if (!regex.hasMatch(value)) {
                            return 'Please enter a valid Gmail address';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 3.0),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 3.0),
                          ),
                          errorBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 3.0),
                          ),
                          focusedErrorBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 3.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              color: Colors.blueGrey,
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          loginUser();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: customColor3,
                          minimumSize: const Size(200, 48),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      child: Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text('Forgot password?',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 15)),
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                  ],
                ),
              )
            ]));
  }
}
