class MeResponse {
  final int id;
  final String username;
  final String fullName;

  const MeResponse({
    required this.id,
    required this.username,
    required this.fullName,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return MeResponse(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
    );
  }
}