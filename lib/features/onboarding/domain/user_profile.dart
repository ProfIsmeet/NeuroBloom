class UserProfile {
  const UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.avatarId,
    required this.createdAt,
    required this.onboardingCompleted,
  });

  final String name;
  final int age;
  final String gender;
  final int avatarId;
  final DateTime createdAt;
  final bool onboardingCompleted;

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    int? avatarId,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      avatarId: avatarId ?? this.avatarId,
      createdAt: createdAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'gender': gender,
    'avatarId': avatarId,
    'createdAt': createdAt.toIso8601String(),
    'onboardingCompleted': onboardingCompleted,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      avatarId: json['avatarId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      onboardingCompleted: json['onboardingCompleted'] as bool,
    );
  }
}
