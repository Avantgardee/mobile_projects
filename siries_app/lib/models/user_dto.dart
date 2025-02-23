class UserDto {
  final String id;
  final String? address;
  final String? bio;
  final String? birthDate;
  final String? chefStatus;
  final String? city;
  final String? country;
  final bool emailVerified;
  final String? firstName;
  final String? gender;
  final String? lastName;
  final String? phone;
  final String regDate;
  final List<String> favoriteRecipes;

  UserDto({
    required this.id,
    this.address = '',
    this.bio = '',
    this.birthDate = '',
    this.chefStatus = '',
    this.city = '',
    this.country = '',
    this.emailVerified = false,
    this.firstName = '',
    this.gender = '',
    this.lastName = '',
    this.phone = '',
    this.regDate = '',
    this.favoriteRecipes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'bio': bio,
      'birthDate': birthDate,
      'chefStatus': chefStatus,
      'city': city,
      'country': country,
      'emailVerified': emailVerified,
      'firstName': firstName,
      'gender': gender,
      'lastName': lastName,
      'phone': phone,
      'regDate': regDate,
      'favoriteRecipes': favoriteRecipes,
    };
  }

  factory UserDto.fromMap(String id, Map<String, dynamic> map) {
    return UserDto(
      id: id,
      address: map['address'] ?? '',
      bio: map['bio'] ?? '',
      birthDate: map['birthDate'] ?? '',
      chefStatus: map['chefStatus'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
      firstName: map['firstName'] ?? '',
      gender: map['gender'] ?? '',
      lastName: map['lastName'] ?? '',
      phone: map['phone'] ?? '',
      regDate: map['regDate'] ?? '',
      favoriteRecipes: List<String>.from(map['favoriteRecipes'] ?? []),
    );
  }

  factory UserDto.fromFirestore(Map<String, dynamic> data, String id) {
    return UserDto(
      id: id,
      address: data['address'] ?? '',
      bio: data['bio'] ?? '',
      birthDate: data['birthDate'] ?? '',
      chefStatus: data['chefStatus'] ?? '',
      city: data['city'] ?? '',
      country: data['country'] ?? '',
      emailVerified: data['emailVerified'] ?? false,
      firstName: data['firstName'] ?? '',
      gender: data['gender'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'] ?? '',
      regDate: data['regDate'] ?? '',
      favoriteRecipes: List<String>.from(data['favoriteRecipes'] ?? []),
    );
  }
}