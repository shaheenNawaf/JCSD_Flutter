class AccountUser {
  final String id;
  final String? name;
  final String email;
  final String phone;

  AccountUser({
    required this.id,
    required this.email,
    required this.phone,
    this.name,
  });

  factory AccountUser.fromJson(Map<String, dynamic> json) {
    final meta = json['raw_user_meta_data'] ?? {};
    return AccountUser(
      id: json['id'],
      email: json['email'] ?? 'No Email',
      phone: json['phone'] ?? 'No Phone',
      name: meta['name'] ?? 'NULL',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name ?? 'NULL',
    };
  }
}
