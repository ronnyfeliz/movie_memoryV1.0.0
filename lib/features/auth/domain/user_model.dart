class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final int age;
  final String photoURL;
  final String gender;
  final String bio;
  final List<String> preferredGenres;
  final List<String> preferredTypes;
  final bool notificationsEnabled;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.photoURL,
    this.gender = '',
    this.bio = '',
    this.preferredGenres = const [],
    this.preferredTypes = const [],
    this.notificationsEnabled = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': '$firstName $lastName',
      'age': age,
      'photoURL': photoURL,
      'gender': gender,
      'bio': bio,
      'preferences': {
        'genres': preferredGenres,
        'types': preferredTypes,
      },
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      age: map['age'] ?? 0,
      photoURL: map['photoURL'] ?? '',
      gender: map['gender'] ?? '',
      bio: map['bio'] ?? '',
      preferredGenres: List<String>.from(map['preferences']?['genres'] ?? []),
      preferredTypes: List<String>.from(map['preferences']?['types'] ?? []),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    int? age,
    String? photoURL,
    String? gender,
    String? bio,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      photoURL: photoURL ?? this.photoURL,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      preferredGenres: preferredGenres,
      preferredTypes: preferredTypes,
      notificationsEnabled: notificationsEnabled,
      createdAt: createdAt,
    );
  }
}
