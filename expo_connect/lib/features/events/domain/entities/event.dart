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
    // Get ID from multiple possible sources
    String getId() {
      if (json['id'] != null && json['id'].toString().isNotEmpty) {
        return json['id'].toString();
      }
      if (json['_id'] != null) {
        if (json['_id'] is String) return json['_id'];
        if (json['_id'] is Map) {
          final idMap = json['_id'] as Map;
          if (idMap.containsKey('\$oid')) {
            return idMap['\$oid'].toString();
          }
        }
        return json['_id'].toString();
      }
      return '';
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
      organizerId: json['organizer']?['_id']?.toString() ?? json['organizerId']?.toString(),
      organizerName: json['organizer']?['firstName']?.toString() ?? json['organizerName']?.toString(),
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
      location: json['location']?['venue']?.toString() ?? json['location']?.toString(),
      ticketPrice: json['ticketPrice'] != null 
          ? double.tryParse(json['ticketPrice'].toString()) 
          : null,
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