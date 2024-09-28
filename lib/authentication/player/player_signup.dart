import 'package:cricket_club_fyp/onboarding/additional_signup_info.dart';
import 'package:flutter/material.dart';

class PlayerSignUpScreen extends StatefulWidget {
  const PlayerSignUpScreen({super.key});

  @override
  State<PlayerSignUpScreen> createState() => _PlayerSignUpScreenState();
}

class _PlayerSignUpScreenState extends State<PlayerSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  Color customColor3 = const Color(0xFF088395);
  final TextEditingController _contactNumberController =
      TextEditingController();
  bool _isPasswordVisible = false;
  Color customColor1 = const Color(0xff0F2630);

  String? _gender;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customColor1,
      body: Padding(
        padding: const EdgeInsets.all(14.0),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40,),
          
              const Text(
                'Let’s Get\nStarted!',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 35),
              ),
              const SizedBox(height: 10,),
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800),
                  children: [
                    const TextSpan(
                      text: 'Hi, what’s your ',
                    ),
                    TextSpan(
                      text: 'name',
                      style: TextStyle(
                          color: customColor3,
                          fontWeight: FontWeight.w800,
                          fontSize: 25),
                    ),
                    const TextSpan(
                      text: '?',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 25),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50,),
          
              Form(
                key: _formKey,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: customColor3, width: 6),
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white
                    ),
                    width: 400,
                    height: 500,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                      child: ListView(
                        children: [
                          TextFormField(
                            style: const TextStyle(color: Colors.black),
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(color: Colors.black),
                              hintStyle: TextStyle(color: Colors.black),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2.0),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width:2.0),
                              ),
                              focusedErrorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16,),
                          TextFormField(
                            controller: _dobController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              labelText: 'Date Of Birth',
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
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _dobController.text =
                                  "${pickedDate.toLocal()}".split(' ')[0];
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Gender:',
                            style: TextStyle(color: Colors.black, fontSize:16),
                          ),
                          RadioListTile<String>(
                            title: const Text(
                              'Male',
                              style: TextStyle(color: Colors.black),
                            ),
                            value: 'Male',
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                            activeColor: customColor3,
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return customColor3;
                                  }
                                  return customColor3;
                                }),
                          ),
                          RadioListTile<String>(
                              title: const Text(
                                'Female',
                                style: TextStyle(color: Colors.black),
                              ),
                              value: 'Female',
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value;
                                });
                              },
                              activeColor:  customColor3,
                              fillColor: MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.selected)) {
                                      return  customColor3;
                                    }
                                    return  customColor3;
                                  })),
                          TextFormField(
                            style: const TextStyle(color: Colors.black),
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
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
                                return 'Please enter your email address';
                              }
                              if (!RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16,),
                          TextFormField(
                            // keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.black),
                            controller: _contactNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Contact Number',
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
                                return 'Please enter your contact number';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Please enter a valid contact number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16,),
                          TextFormField(
                            controller: _passwordController,
                            decoration:  InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.black),
                              hintStyle: const TextStyle(color: Colors.black),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black, width: 2.0),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black, width: 2.0),
                              ),
                              errorBorder: const UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.red, width: 2.0),
                              ),
                              focusedErrorBorder: const UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.red, width: 2.0),
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

                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 16,),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration:  InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: const TextStyle(color: Colors.black),
                              hintStyle: const TextStyle(color: Colors.black),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black, width: 2.0),
                              ),
                              focusedBorder:const UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black, width: 2.0),
                              ),
                              errorBorder:const UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.red, width: 2.0),
                              ),
                              focusedErrorBorder: const UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.red, width: 2.0),
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
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 20,),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() == true) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => OptionalOnboarding(
                                        name: _nameController.text,
                                        dob: _dobController.text,
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                        gender: _gender,
                                        contactNumber: _contactNumberController.text,
                                      )),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                             backgroundColor: customColor3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
          
          
                              ),
                              fixedSize: const Size(200, 50),
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
          
                        ],
                      ),
          
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
