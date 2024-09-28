import 'package:cricket_club_fyp/start-screens/login-signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class PlayerorClub extends StatefulWidget {
  const PlayerorClub({super.key});

  @override
  State<PlayerorClub> createState() => _PlayerorClubState();
}

class _PlayerorClubState extends State<PlayerorClub> {


  Color customColor1 = const Color(0xff0F2630);
  Color customColor2 = const Color(0xff0F2630);
  Color customColor3 = const Color(0xFF088395);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [customColor1, customColor2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "What are you?",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            //player
            const SizedBox(height: 20.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200.0,
                  height: 48.0,
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const Journey()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customColor3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: Container(
                      height: 48.0,
                      alignment: Alignment.center,
                      child: Text(
                        "Player",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),



                const SizedBox(height: 16.0),
                const Text("or", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 16.0),

                SizedBox(
                  width: 200.0,
                  height: 48.0,
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const Journey()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 48.0,
                          alignment: Alignment.center,
                          child: Text(
                            "Host",
                            style: GoogleFonts.poppins(
                              color: customColor2,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}