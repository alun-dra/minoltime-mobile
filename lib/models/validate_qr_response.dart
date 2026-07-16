class ValidateQrUser {
  final int id;
  final String username;
  final String firstName;

  const ValidateQrUser({
    required this.id,
    required this.username,
    required this.firstName,
  });

  factory ValidateQrUser.fromJson(Map<String, dynamic> json) {
    return ValidateQrUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
    );
  }
}

class ValidateQrResponse {
  final String status;
  final ValidateQrUser? user;
  final String message;
  final String timestamp;

  final int? userId;
  final int? branchId;
  final int? accessPointId;
  final String? workDate;
  final String? workInAt;
  final String? breakOutAt;
  final String? breakInAt;
  final String? workOutAt;

  final int? lateMinutes;
  final int? overtimeMinutes;
  final int? earlyExitMinutes;
  final int? breakDiffMinutes;

  const ValidateQrResponse({
    required this.status,
    required this.user,
    required this.message,
    required this.timestamp,
    this.userId,
    this.branchId,
    this.accessPointId,
    this.workDate,
    this.workInAt,
    this.breakOutAt,
    this.breakInAt,
    this.workOutAt,
    this.lateMinutes,
    this.overtimeMinutes,
    this.earlyExitMinutes,
    this.breakDiffMinutes,
  });

  factory ValidateQrResponse.fromJson(Map<String, dynamic> json) {
    return ValidateQrResponse(
      status: json['status'] ?? '',
      user: json['user'] != null
          ? ValidateQrUser.fromJson(json['user'])
          : null,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
      userId: json['user_id'],
      branchId: json['branch_id'],
      accessPointId: json['access_point_id'],
      workDate: json['work_date'],
      workInAt: json['work_in_at'],
      breakOutAt: json['break_out_at'],
      breakInAt: json['break_in_at'],
      workOutAt: json['work_out_at'],
      lateMinutes: json['late_minutes'],
      overtimeMinutes: json['overtime_minutes'],
      earlyExitMinutes: json['early_exit_minutes'],
      breakDiffMinutes: json['break_diff_minutes'],
    );
  }
}