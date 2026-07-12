import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phone,
    required super.role,
    super.profilePicture,
    required super.isEmailVerified,
    super.bio,
    super.companyId,
    super.interests,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle null values gracefully
    return UserModel(
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
      '_id': id,
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

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phone: user.phone,
      role: user.role,
      profilePicture: user.profilePicture,
      isEmailVerified: user.isEmailVerified,
      bio: user.bio,
      companyId: user.companyId,
      interests: user.interests,
      createdAt: user.createdAt,
    );
  }
}