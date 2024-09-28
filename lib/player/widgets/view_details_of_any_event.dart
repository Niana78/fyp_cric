import 'package:cricket_club_fyp/constants/const_exports.dart';
import 'package:cricket_club_fyp/view_match_stats/view_match_stats.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:cricket_club_fyp/models/event_model.dart';
import '../../configurations/config.dart';

class ViewDetailsOfAnyEvent extends StatefulWidget {
  const ViewDetailsOfAnyEvent({
    super.key,
    required this.name,
    required this.location,
    required this.totalPlayers,
    required this.matchDate,
    required this.matchTime,
    required this.notes,
    required this.createdBy,
    required this.host,
    required this.matchId,
    required this.userId,
    required this.playerStats,
  });

final List<PlayerStats> playerStats;
  final String host;
  final String name;
  final String location;
  final int totalPlayers;
  final String matchDate;
  final String matchTime;
  final String notes;
  final String createdBy;
  final String matchId;
  final String userId;

  @override
  State<ViewDetailsOfAnyEvent> createState() => _ViewDetailsOfAnyEventState();
}

class _ViewDetailsOfAnyEventState extends State<ViewDetailsOfAnyEvent> {
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    checkIfMatchIsSaved();
  }

  Future<void> checkIfMatchIsSaved() async {
    final response = await http.get(
      Uri.parse('$getsavedmatches${widget.userId}/saved-matches'),
    );

    if (response.statusCode == 200) {
      setState(() {
        isSaved = true; // Match is saved
      });
    }
  }

  Future<void> saveMatch() async {
    // print("thisi id the uri '$savematch${widget.userId}/matches/${widget.matchId}/save'");
    final response = await http.post(
      Uri.parse('$savematch${widget.userId}/matches/${widget.matchId}/save'),
    );

    if (response.statusCode == 200) {
      setState(() {
        isSaved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event successfully saved!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save the event.")),
      );
    }
  }

  Future<void> unsaveMatch() async {
    final response = await http.delete(
      Uri.parse('$unsavematch${widget.userId}/matches/${widget.matchId}/unsave'),
    );

    if (response.statusCode == 200) {
      setState(() {
        isSaved = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event unsaved successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to unsave the event.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime eventDate = DateTime.parse(widget.matchDate);
    DateTime currentDate = DateTime.now();
    bool isEventInPast = eventDate.isBefore(currentDate);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              if (isSaved) {
                unsaveMatch();
              } else {
                saveMatch();
              }
            },
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border, // Change icon based on saved state
              color: isSaved ? Colors.green : CricketClubTheme().maincolor, // Color change
            ),
          ),
          IconButton(
            onPressed: () {
              shareToWhatsApp(
                  '''
Dear Sir/Madam,

We are pleased to invite you to a Cricket Event that will take place at the following location:
Name: ${widget.name}
Address: ${widget.location}
Date: ${widget.matchDate}
Time: ${widget.matchTime}
Host: ${widget.host}

We hope to see you there.

Best regards,
Cricket Club
'''
              );
            },
            icon: Image.asset(
              CricClubAssets.share,
              width: 24,
              height: 24,
            ),
          ),
        ],
        title: Text(
          "Return",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CricketClubTheme().maincolor,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Material(
            elevation: 4,
            color: CricketClubTheme().white,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: 37,
              height: 37,
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: CricketClubTheme().maincolor,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "OTP (Open to Public)",
              style: CricketTextTheme().heading7.copyWith(
                fontWeight: FontWeight.w500,
                color: CricketClubTheme().eeriesturquoise,
              ),
            ),
            SizedBoxes.vertical10Px,
            Text(
              "Match @ ${widget.location}",
              style: CricketTextTheme().heading2.copyWith(
                fontWeight: FontWeight.w700,
                color: CricketClubTheme().maincolor,
              ),
            ),
            SizedBoxes.vertical3Px,
            const Divider(
              color: Color.fromARGB(255, 90, 89, 89),
            ),
            SizedBoxes.vertical10Px,
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      textAlign: TextAlign.left,
                      "Date",
                      style: CricketTextTheme().heading6.copyWith(
                        fontWeight: FontWeight.w700,
                        color: CricketClubTheme().maincolor,
                      ),
                    ),
                    SizedBoxes.vertical10Px,
                    Text(
                      _formatDate(widget.matchDate),
                      style: CricketTextTheme().heading7.copyWith(
                        fontWeight: FontWeight.w500,
                        color: CricketClubTheme().black,
                      ),
                    ),
                  ],
                ),
                SizedBoxes.horizontalExtrasbigGargangua,
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Time",
                        style: CricketTextTheme().heading6.copyWith(
                          fontWeight: FontWeight.w700,
                          color: CricketClubTheme().maincolor,
                        ),
                      ),
                      SizedBoxes.vertical10Px,
                      Text(
                        widget.matchTime,
                        style: CricketTextTheme().heading6.copyWith(
                          fontWeight: FontWeight.w500,
                          color: CricketClubTheme().black,
                        ),
                        textAlign: MediaQuery.of(context).size.width < 600
                            ? TextAlign.right
                            : TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBoxes.verticalBig,
            Text(
              "Host",
              style: CricketTextTheme().heading6.copyWith(
                fontWeight: FontWeight.w700,
                color: CricketClubTheme().maincolor,
              ),
            ),
            SizedBoxes.vertical10Px,
            Text(
              widget.host,
              style: CricketTextTheme().heading7.copyWith(
                fontWeight: FontWeight.w500,
                color: CricketClubTheme().black,
              ),
            ),
            SizedBoxes.verticalBig,
            Text(
              "Address",
              style: CricketTextTheme().heading6.copyWith(
                fontWeight: FontWeight.w700,
                color: CricketClubTheme().maincolor,
              ),
            ),
            SizedBoxes.vertical10Px,
            Text(
              widget.location,
              style: CricketTextTheme().heading7.copyWith(
                fontWeight: FontWeight.w500,
                color: CricketClubTheme().black,
              ),
            ),
            SizedBoxes.verticalBig,
            Text(
              "Notes from Host",
              style: CricketTextTheme().heading6.copyWith(
                fontWeight: FontWeight.w700,
                color: CricketClubTheme().maincolor,
              ),
            ),
            SizedBoxes.vertical10Px,
            Text(
              widget.notes,
              style: CricketTextTheme().body.copyWith(
                fontWeight: FontWeight.w600,
                color: CricketClubTheme().black,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isEventInPast
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewMatchStats(
                  matchEvent: Event(
                    id: widget.matchId,
                    name: widget.name,
                    location: widget.location,
                    matchDate: widget.matchDate,
                    totalPlayers: widget.totalPlayers,
                    createdBy: widget.createdBy,
                    matchTime: widget.matchTime,
                    notes: widget.notes,
                    host: widget.host,
                    playerStats: widget.playerStats,
                  ),
                ),
              ),
            );
          },
          child: Text("View Stats"),
          style: ElevatedButton.styleFrom(
            backgroundColor: CricketClubTheme().maincolor,
            foregroundColor: CricketClubTheme().white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      )
          : null,
    );
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return formatter.format(parsedDate);
  }

  void shareToWhatsApp(String message) {
    Share.share(message);
  }
}
