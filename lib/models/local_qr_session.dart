class LocalQrSession {
  final String token;
  final int expiresIn;
  final String expiresAt;

  const LocalQrSession({
    required this.token,
    required this.expiresIn,
    required this.expiresAt,
  });

  factory LocalQrSession.fromJson(Map<String, dynamic> json) {
    return LocalQrSession(
      token: json['token'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
      expiresAt: json['expires_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expires_in': expiresIn,
      'expires_at': expiresAt,
    };
  }

  bool get isExpired {
    if (expiresAt.isEmpty) return true;

    final expiresDate = DateTime.tryParse(expiresAt);
    if (expiresDate == null) return true;

    return DateTime.now().isAfter(expiresDate);
  }

  int get remainingSeconds {
    if (expiresAt.isEmpty) return 0;

    final expiresDate = DateTime.tryParse(expiresAt);
    if (expiresDate == null) return 0;

    final diff = expiresDate.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }
}