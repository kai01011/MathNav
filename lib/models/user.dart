class User {
  final String? id; // Add id field
  final String username;
  final String email; // Add email field
  final String password;
  final String name;
  final int grade;
  final String? gender; // Add gender field
  final String? batch; // Add batch/enrollment field
  final DateTime registrationDate;
  final String? firebaseUid; // Optional Firebase UID

  User({
    this.id,
    required this.username,
    required this.email, // Add email
    required this.password,
    required this.name,
    required this.grade,
    this.gender, // Add gender
    this.batch, // Add batch
    required this.registrationDate,
    this.firebaseUid,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id ??
          firebaseUid ??
          username, // Use firebaseUid or username as fallback
      'username': username,
      'email': email, // Add email to JSON
      'password': password,
      'name': name,
      'grade': grade,
      'gender': gender, // Add gender to JSON
      'batch': batch, // Add batch to JSON
      'registrationDate': registrationDate.toIso8601String(),
      'firebaseUid': firebaseUid,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['firebaseUid'] ?? json['username'],
      username: json['username'],
      email: json['email'] ?? '', // Handle old users without email
      password: json['password'],
      name: json['name'],
      grade: json['grade'],
      gender: json['gender'], // Add gender
      batch: json['batch'], // Add batch
      registrationDate: DateTime.parse(json['registrationDate']),
      firebaseUid: json['firebaseUid'],
    );
  }
}
