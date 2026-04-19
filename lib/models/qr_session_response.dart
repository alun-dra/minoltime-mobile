class QrSessionResponse {
  final String token;
  final int expiresIn;

  const QrSessionResponse({
    required this.token,
    required this.expiresIn,
  });

  factory QrSessionResponse.fromJson(Map<String, dynamic> json) {
    return QrSessionResponse(
      token: json['token'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
    );
  }
}