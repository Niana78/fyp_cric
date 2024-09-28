class Event {
  final String name;
  final String location;
  final String matchDate;
  final int totalPlayers;
  final String createdBy;
  final String matchTime;
  final String host;
  final String notes;
  final String id;
  final List<PlayerStats> playerStats;

  Event({
    required this.id,
    required this.name,
    required this.location,
    required this.matchDate,
    required this.totalPlayers,
    required this.createdBy,
    required this.matchTime,
    required this.notes,
    required this.host,
    required this.playerStats,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    print('Parsing Event JSON: $json'); // Debugging statement

    var playerStatsJson = json['playersStats'] as List<dynamic>?; // Correct key

    return Event(
      id: json['_id'] ?? '',
      host: json['hostName'] ?? 'Javeria',
      name: json['matchName'] ?? '',
      location: json['matchLocation'] ?? '',
      matchDate: json['matchDate'] ?? '',
      totalPlayers: json['totalPlayers'] ?? 0,
      createdBy: json['createdBy'] ?? '',
      matchTime: json['matchTime'] ?? '',
      notes: json['notes'] ?? '',
      playerStats: playerStatsJson?.map((stat) {
        print('Parsing PlayerStat JSON: $stat'); // Debugging statement
        return PlayerStats.fromJson(stat);
      }).toList() ?? [],  // Handle null playerStats gracefully
    );
  }
}

class PlayerStats {
  final String playerName;
  final int runs;
  final int wickets;
  final int catches;
  final String id;  // Add _id field if needed

  PlayerStats({
    required this.playerName,
    required this.runs,
    required this.wickets,
    required this.catches,
    required this.id,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      playerName: json['playerName'] ?? '',
      runs: json['runs'] ?? 0,
      wickets: json['wickets'] ?? 0,
      catches: json['catches'] ?? 0,
      id: json['_id'] ?? '',  // Map the _id field
    );
  }
}
