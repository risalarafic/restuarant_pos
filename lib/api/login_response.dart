class LoginUserDetails {
  const LoginUserDetails({
    required this.id,
    required this.name,
    required this.restaurantId,
    required this.restaurantName,
    this.email = '',
    this.password = '',
  });

  final String id;
  final String name;
  final String restaurantId;
  final String restaurantName;
  // Kept in memory only (not persisted to prefs) for dashboard API call
  final String email;
  final String password;

  factory LoginUserDetails.fromJson(Map<String, dynamic> json) {
    return LoginUserDetails(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      restaurantId: '${json['restaurantid'] ?? ''}',
      restaurantName: '${json['restaurantname'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'restaurantid': restaurantId,
        'restaurantname': restaurantName,
      };
}

class LoginResponse {
  const LoginResponse({
    required this.success,
    this.authToken,
    this.user,
    this.message,
  });

  final bool success;
  final String? authToken;
  final LoginUserDetails? user;
  final String? message;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['userdtls'];
    return LoginResponse(
      success: json['success'] == true,
      authToken: json['auth_token'] as String?,
      user: userJson is Map<String, dynamic>
          ? LoginUserDetails.fromJson(userJson)
          : null,
      message: json['message'] as String?,
    );
  }
}
