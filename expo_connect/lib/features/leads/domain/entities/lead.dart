class Lead {
  final String id;
  final String exhibitorId;
  final String visitorId;
  final String visitorName;
  final String visitorEmail;
  final String? visitorProfilePicture;
  final String eventId;
  final String eventTitle;
  final int interestLevel;
  final int score;
  final String status;
  final String notes;
  final DateTime? followUpDate;
  final List<Interaction> interactions;
  final String source;
  final DateTime createdAt;

  Lead({
    required this.id,
    required this.exhibitorId,
    required this.visitorId,
    required this.visitorName,
    required this.visitorEmail,
    this.visitorProfilePicture,
    required this.eventId,
    required this.eventTitle,
    required this.interestLevel,
    required this.score,
    required this.status,
    required this.notes,
    this.followUpDate,
    required this.interactions,
    required this.source,
    required this.createdAt,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    final visitor = json['visitor'] ?? {};
    final event = json['event'] ?? {};

    return Lead(
      id: json['_id'] ?? json['id'] ?? '',
      exhibitorId: json['exhibitor']?['_id'] ?? json['exhibitorId'] ?? '',
      visitorId: visitor['_id'] ?? visitor['id'] ?? '',
      visitorName: visitor['firstName'] != null && visitor['lastName'] != null
          ? '${visitor['firstName']} ${visitor['lastName']}'
          : 'Unknown Visitor',
      visitorEmail: visitor['email'] ?? '',
      visitorProfilePicture: visitor['profilePicture'],
      eventId: event['_id'] ?? event['id'] ?? '',
      eventTitle: event['title'] ?? 'Unknown Event',
      interestLevel: json['interestLevel'] ?? 5,
      score: json['score'] ?? 0,
      status: json['status'] ?? 'new',
      notes: json['notes'] ?? '',
      followUpDate: json['followUpDate'] != null
          ? DateTime.parse(json['followUpDate'])
          : null,
      interactions: json['interactions'] != null
          ? (json['interactions'] as List)
              .map((i) => Interaction.fromJson(i))
              .toList()
          : [],
      source: json['source'] ?? 'manual',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class Interaction {
  final String type;
  final String description;
  final DateTime date;

  Interaction({
    required this.type,
    required this.description,
    required this.date,
  });

  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      type: json['type'] ?? 'message',
      description: json['description'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }
}