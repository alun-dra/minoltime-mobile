class LoginResponse {
  final String accessToken;
  final String expiresAt;
  final int expiresIn;
  final String refreshExpiresAt;
  final String refreshToken;
  final String role;
  final String tokenType;
  final String username;

  const LoginResponse({
    required this.accessToken,
    required this.expiresAt,
    required this.expiresIn,
    required this.refreshExpiresAt,
    required this.refreshToken,
    required this.role,
    required this.tokenType,
    required this.username,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
      refreshExpiresAt: json['refresh_expires_at'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      role: json['role'] ?? '',
      tokenType: json['token_type'] ?? '',
      username: json['username'] ?? '',
    );
  }
}