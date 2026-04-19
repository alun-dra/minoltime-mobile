class LoginResponse {
  final String accessToken;
  final String expiresAt;
  final int expiresIn;
  final String refreshExpiresAt;
  final String refreshToken;
  final String role;
  final String tokenType;
  final String username;

  final int? deviceId;
  final int? accessPointId;
  final String? direction;
  final String? name;

  const LoginResponse({
    required this.accessToken,
    required this.expiresAt,
    required this.expiresIn,
    required this.refreshExpiresAt,
    required this.refreshToken,
    required this.role,
    required this.tokenType,
    required this.username,
    this.deviceId,
    this.accessPointId,
    this.direction,
    this.name,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ??
          json['AccessToken'] ??
          '',
      expiresAt: json['expires_at'] ??
          json['ExpiresAt'] ??
          '',
      expiresIn: json['expires_in'] ??
          json['ExpiresIn'] ??
          0,
      refreshExpiresAt: json['refresh_expires_at'] ??
          json['RefreshExpiresAt'] ??
          '',
      refreshToken: json['refresh_token'] ??
          json['RefreshToken'] ??
          '',
      role: json['role'] ??
          json['Role'] ??
          '',
      tokenType: json['token_type'] ??
          json['TokenType'] ??
          '',
      username: json['username'] ??
          json['Username'] ??
          '',
      deviceId: json['device_id'] ??
          json['DeviceID'],
      accessPointId: json['access_point_id'] ??
          json['AccessPointID'],
      direction: json['direction'] ??
          json['Direction'],
      name: json['name'] ??
          json['Name'],
    );
  }
}