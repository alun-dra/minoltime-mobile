class MeResponse {
  final String username;
  final String fullName;

  const MeResponse({
    required this.username,
    required this.fullName,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return MeResponse(
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
    );
  }
}