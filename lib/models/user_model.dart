class User {
  String? id;
  String? name;
  String? email;
  String? password;
  DateTime? dateOfBirth;
  String? gender;
  String? contactNumber;
  String? cnicFront;
  String? cnicBack;
  String? address;
  String? country;
  String? category;
  String? experienceDoc;
  List<String>? affiliatedOrganizations;
  String? userId;
  String? profilePictureUrl;

  User({
    this.profilePictureUrl,
    this.id,
    this.name,
    this.email,
    this.password,
    this.dateOfBirth,
    this.gender,
    this.contactNumber,
    this.cnicFront,
    this.cnicBack,
    this.address,
    this.country,
    this.category,
    this.experienceDoc,
    this.affiliatedOrganizations,
    this.userId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      gender: json['gender'],
      contactNumber: json['contactNumber'],
      cnicFront: json['cnicFront'],
      cnicBack: json['cnicBack'],
      address: json['address'],
      country: json['country'],
      category: json['category'],
      experienceDoc: json['experienceDoc'],
      affiliatedOrganizations: json['affiliatedOrganizations'] != null
          ? List<String>.from(json['affiliatedOrganizations'])
          : null,
      userId: json['userId'],
      profilePictureUrl: json['profilePictureUrl']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'password': password,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'contactNumber': contactNumber,
      'cnicFront': cnicFront,
      'cnicBack': cnicBack,
      'address': address,
      'country': country,
      'category': category,
      'experienceDoc': experienceDoc,
      'affiliatedOrganizations': affiliatedOrganizations,
      'userId': userId,
      'profilePictureUrl': profilePictureUrl
    };
  }
}
