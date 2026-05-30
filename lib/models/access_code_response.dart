class AccessCodeResponse {
  final String accessCode;

  const AccessCodeResponse({
    required this.accessCode,
  });

  factory AccessCodeResponse.fromJson(Map<String, dynamic> json) {
    return AccessCodeResponse(
      accessCode: json['access_code'] ?? '',
    );
  }
}