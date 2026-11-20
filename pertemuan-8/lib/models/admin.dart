class Admin {
  const Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
  });

  final int id;
  final String name;
  final String email;
  final String department;

  factory Admin.fromJson(Map<String, dynamic> json) {
    final company = json['company'];
    final departmentValue =
        json['department'] ??
        (company is Map<String, dynamic> ? company['name'] : null);
    return Admin(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: departmentValue?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'department': department,
  };
}
