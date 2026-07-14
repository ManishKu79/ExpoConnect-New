class Event {
  final String id;
  final String title;
  final String description;
  final String? banner;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? organizerId;
  final String? organizerName;
  final int? maxAttendees;
  final int? registeredCount;
  final bool isPublic;
  final List<String> categories;
  final String? location;
  final double? ticketPrice;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.banner,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.organizerId,
    this.organizerName,
    this.maxAttendees,
    this.registeredCount,
    required this.isPublic,
    this.categories = const [],
    this.location,
    this.ticketPrice,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Handle both _id and id fields
    final idValue = json['_id'] ?? json['id'] ?? '';
    final id = idValue is String ? idValue : idValue.toString();
    
    return Event(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      banner: json['banner'],
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : DateTime.now(),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : DateTime.now().add(const Duration(hours: 1)),
      status: json['status'] ?? 'draft',
      organizerId: json['organizer']?['_id']?.toString() ?? json['organizerId'],
      organizerName: json['organizer']?['firstName'] ?? json['organizerName'],
      maxAttendees: json['maxAttendees'],
      registeredCount: json['registeredCount'],
      isPublic: json['isPublic'] ?? true,
      categories: json['categories'] != null 
          ? List<String>.from(json['categories']) 
          : [],
      location: json['location']?['venue'] ?? json['location'],
      ticketPrice: json['ticketPrice']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'banner': banner,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'maxAttendees': maxAttendees,
      'registeredCount': registeredCount,
      'isPublic': isPublic,
      'categories': categories,
      'location': location,
      'ticketPrice': ticketPrice,
    };
  }
}