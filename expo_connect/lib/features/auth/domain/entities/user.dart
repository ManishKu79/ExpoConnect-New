class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String role;
  final String? profilePicture;
  final bool isEmailVerified;
  final String? bio;
  final String? companyId;
  final List<String>? interests;
  final DateTime createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.role,
    this.profilePicture,
    required this.isEmailVerified,
    this.bio,
    this.companyId,
    this.interests,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle null values gracefully
    return User(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'visitor',
      profilePicture: json['profilePicture']?.toString(),
      isEmailVerified: json['isEmailVerified'] ?? false,
      bio: json['bio']?.toString(),
      companyId: json['company']?.toString(),
      interests: json['interests'] != null 
          ? List<String>.from(json['interests']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'profilePicture': profilePicture,
      'isEmailVerified': isEmailVerified,
      'bio': bio,
      'company': companyId,
      'interests': interests,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? profilePicture,
    String? bio,
    List<String>? interests,
  }) {
    return User(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
      phone: phone ?? this.phone,
      role: role,
      profilePicture: profilePicture ?? this.profilePicture,
      isEmailVerified: isEmailVerified,
      bio: bio ?? this.bio,
      companyId: companyId,
      interests: interests ?? this.interests,
      createdAt: createdAt,
    );
  }
}