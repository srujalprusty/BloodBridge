import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { donor, requester, hospital }

class UserModel {
  final String uid;
  final String phone;
  final String name;
  final UserRole role;
  final String bloodGroup;
  final double latitude;
  final double longitude;
  final bool availability;
  final DateTime? lastDonated;
  final int totalDonations;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.phone,
    this.name = '',
    this.role = UserRole.donor,
    this.bloodGroup = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.availability = true,
    this.lastDonated,
    this.totalDonations = 0,
    required this.createdAt,
  });

  // Check if eligible to donate (56 days since last donation)
  bool get isEligibleToDonate {
    if (lastDonated == null) return true;
    final daysSince = DateTime.now().difference(lastDonated!).inDays;
    return daysSince >= 56;
  }

  // Days until eligible
  int get daysUntilEligible {
    if (lastDonated == null) return 0;
    final daysSince = DateTime.now().difference(lastDonated!).inDays;
    return (56 - daysSince).clamp(0, 56);
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      phone: data['phone'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == (data['role'] ?? 'donor'),
        orElse: () => UserRole.donor,
      ),
      bloodGroup: data['blood_group'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      availability: data['availability'] ?? true,
      lastDonated: data['last_donated'] != null
          ? (data['last_donated'] as Timestamp).toDate()
          : null,
      totalDonations: data['total_donations'] ?? 0,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'phone': phone,
      'name': name,
      'role': role.name,
      'blood_group': bloodGroup,
      'latitude': latitude,
      'longitude': longitude,
      'availability': availability,
      'last_donated': lastDonated != null ? Timestamp.fromDate(lastDonated!) : null,
      'total_donations': totalDonations,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    UserRole? role,
    String? bloodGroup,
    double? latitude,
    double? longitude,
    bool? availability,
    DateTime? lastDonated,
    int? totalDonations,
  }) {
    return UserModel(
      uid: uid,
      phone: phone,
      name: name ?? this.name,
      role: role ?? this.role,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      availability: availability ?? this.availability,
      lastDonated: lastDonated ?? this.lastDonated,
      totalDonations: totalDonations ?? this.totalDonations,
      createdAt: createdAt,
    );
  }
}
