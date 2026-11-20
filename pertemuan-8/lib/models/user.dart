class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
  });

  final int id;
  final String name;
  final String email;
  final String city;

  factory User.fromJson(Map<String, dynamic> json) {
    final address = json['address'];
    final cityValue =
        json['city'] ??
        (address is Map<String, dynamic> ? address['city'] : null);
    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      city: cityValue?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'city': city,
  };
}
