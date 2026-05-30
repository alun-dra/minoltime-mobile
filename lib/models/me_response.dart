class MeBranchAccessPoint {
  final int id;
  final String name;
  final bool isActive;

  const MeBranchAccessPoint({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory MeBranchAccessPoint.fromJson(Map<String, dynamic> json) {
    return MeBranchAccessPoint(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}

class MeBranch {
  final int id;
  final String name;
  final String code;
  final bool isActive;
  final List<MeBranchAccessPoint> accessPoints;

  const MeBranch({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    required this.accessPoints,
  });

  factory MeBranch.fromJson(Map<String, dynamic> json) {
    final accessPointsJson = json['access_points'] as List<dynamic>? ?? [];

    return MeBranch(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      isActive: json['is_active'] ?? false,
      accessPoints: accessPointsJson
          .map((item) => MeBranchAccessPoint.fromJson(item))
          .toList(),
    );
  }
}

class MeCurrentShift {
  final int shiftId;
  final String name;
  final String description;
  final String startTime;
  final String endTime;
  final int breakMinutes;
  final bool crossesMidnight;
  final List<String> workDays;

  const MeCurrentShift({
    required this.shiftId,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.breakMinutes,
    required this.crossesMidnight,
    required this.workDays,
  });

  factory MeCurrentShift.fromJson(Map<String, dynamic> json) {
    final workDaysJson = json['work_days'] as List<dynamic>? ?? [];

    return MeCurrentShift(
      shiftId: json['shift_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      breakMinutes: json['break_minutes'] ?? 0,
      crossesMidnight: json['crosses_midnight'] ?? false,
      workDays: workDaysJson.map((item) => item.toString()).toList(),
    );
  }
}

class MeTodaySummary {
  final String workDate;
  final int markingsCount;
  final int workedMinutes;
  final String workedHours;

  const MeTodaySummary({
    required this.workDate,
    required this.markingsCount,
    required this.workedMinutes,
    required this.workedHours,
  });

  factory MeTodaySummary.fromJson(Map<String, dynamic> json) {
    return MeTodaySummary(
      workDate: json['work_date'] ?? '',
      markingsCount: json['markings_count'] ?? 0,
      workedMinutes: json['worked_minutes'] ?? 0,
      workedHours: json['worked_hours'] ?? '',
    );
  }
}

class MeAttendanceHistoryItem {
  final String status;
  final String timestamp;
  final String accessPointName;
  final String direction;

  const MeAttendanceHistoryItem({
    required this.status,
    required this.timestamp,
    required this.accessPointName,
    required this.direction,
  });

  factory MeAttendanceHistoryItem.fromJson(Map<String, dynamic> json) {
    return MeAttendanceHistoryItem(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
      accessPointName: json['access_point_name'] ?? '',
      direction: json['direction'] ?? '',
    );
  }
}

class MeResponse {
  final int id;
  final String username;
  final String role;
  final bool isActive;

  final List<MeBranch> branches;
  final MeCurrentShift? currentShift;
  final MeTodaySummary? todaySummary;
  final List<MeAttendanceHistoryItem> attendanceHistory;

  const MeResponse({
    required this.id,
    required this.username,
    required this.role,
    required this.isActive,
    required this.branches,
    required this.currentShift,
    required this.todaySummary,
    required this.attendanceHistory,
  });

  String get fullName => username;

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    final branchesJson = json['branches'] as List<dynamic>? ?? [];
    final attendanceHistoryJson =
        json['attendance_history'] as List<dynamic>? ?? [];

    return MeResponse(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? false,
      branches: branchesJson.map((item) => MeBranch.fromJson(item)).toList(),
      currentShift: json['current_shift'] != null
          ? MeCurrentShift.fromJson(json['current_shift'])
          : null,
      todaySummary: json['today_summary'] != null
          ? MeTodaySummary.fromJson(json['today_summary'])
          : null,
      attendanceHistory: attendanceHistoryJson
          .map((item) => MeAttendanceHistoryItem.fromJson(item))
          .toList(),
    );
  }
}