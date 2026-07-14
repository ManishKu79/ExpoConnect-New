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
    // Handle _id safely - it could be String, ObjectId, or null
    String getId() {
      final idValue = json['_id'] ?? json['id'];
      if (idValue == null) return '';
      if (idValue is String) return idValue;
      if (idValue is Map) return idValue['\$oid']?.toString() ?? '';
      return idValue.toString();
    }

    // Handle organizer safely
    String? getOrganizerId() {
      final org = json['organizer'];
      if (org == null) return json['organizerId']?.toString();
      if (org is String) return org;
      if (org is Map) return org['_id']?.toString() ?? org['id']?.toString();
      return org.toString();
    }

    String? getOrganizerName() {
      final org = json['organizer'];
      if (org == null) return json['organizerName'];
      if (org is Map) return org['firstName'] ?? org['name'];
      return null;
    }

    // Handle location safely
    String? getLocation() {
      final loc = json['location'];
      if (loc == null) return null;
      if (loc is String) return loc;
      if (loc is Map) return loc['venue']?.toString() ?? loc['city']?.toString();
      return null;
    }

    return Event(
      id: getId(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      banner: json['banner']?.toString(),
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'].toString()) 
          : DateTime.now(),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'].toString()) 
          : DateTime.now().add(const Duration(hours: 1)),
      status: json['status']?.toString() ?? 'draft',
      organizerId: getOrganizerId(),
      organizerName: getOrganizerName(),
      maxAttendees: json['maxAttendees'] != null 
          ? int.tryParse(json['maxAttendees'].toString()) 
          : null,
      registeredCount: json['registeredCount'] != null 
          ? int.tryParse(json['registeredCount'].toString()) 
          : null,
      isPublic: json['isPublic'] ?? true,
      categories: json['categories'] != null 
          ? List<String>.from(json['categories']) 
          : [],
      location: getLocation(),
      ticketPrice: json['ticketPrice'] != null 
          ? double.tryParse(json['ticketPrice'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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