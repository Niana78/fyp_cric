import 'package:cricket_club_fyp/constants/const_exports.dart';
import 'package:cricket_club_fyp/host/widgets/search_players.dart';
import 'package:cricket_club_fyp/host/widgets/search_players_bottom_sheet.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ViewDeatilsAndInvite extends StatefulWidget {
  const ViewDeatilsAndInvite(
      {super.key,
      required this.name,
      required this.location,
      required this.totalPlayers,
      required this.matchDate,
      required this.matchTime,
      required this.notes,
      required this.createdBy,
      required this.host});

  final String host;
  final String name;
  final String location;
  final int totalPlayers;
  final String matchDate;
  final String matchTime;
  final String notes;
  final String createdBy;

  @override
  State<ViewDeatilsAndInvite> createState() => _ViewDeatilsAndInviteState();
}

class _ViewDeatilsAndInviteState extends State<ViewDeatilsAndInvite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                    heightFactor: 0.7,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          left: 8.0,
                          right: 8.0,
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: SearchPlayersBottomSheet(
                          name: widget.name,
                          location: widget.location,
                          matchDate: widget.matchDate,
                          totalPlayers: widget.totalPlayers,
                          createdBy: widget.createdBy,
                          matchTime: widget.matchTime,
                          notes: widget.notes,
                          host: widget.host,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            icon: Image.asset(
              CricClubAssets.invite,
              width: 28,
            ),
          ),

          IconButton(
              onPressed: () {
                shareToWhatsApp('''
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
''');
              },
              icon: Image.asset(
                CricClubAssets.share,
                width: 24,
                height: 24,
              ))
        ],
        title: Text(
          "Return",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CricketClubTheme().maincolor),
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
        child: Padding(
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
      ),
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
