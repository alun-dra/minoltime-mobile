import 'package:flutter/material.dart';

import '../core/api_error_handler.dart';
import '../core/auth_exceptions.dart';
import '../models/me_response.dart';
import '../services/user_service.dart';
import '../widgets/user/mark_record_item.dart';
import '../widgets/user/marks_filter_tabs.dart';
import '../widgets/user/marks_summary_card.dart';
import '../widgets/user/work_schedule_card.dart';

class UserMarksScreen extends StatefulWidget {
  const UserMarksScreen({super.key});

  @override
  State<UserMarksScreen> createState() => _UserMarksScreenState();
}

class _UserMarksScreenState extends State<UserMarksScreen> {
  final UserService _userService = const UserService();

  String selectedFilter = 'Diario';
  final List<String> filters = ['Diario', 'Semanal', 'Mensual', 'Anual'];

  MeResponse? me;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMarksData();
  }

  Future<void> _loadMarksData() async {
    try {
      final response = await _userService.getMe();

      if (!mounted) return;

      setState(() {
        me = response;
        isLoading = false;
        errorMessage = null;
      });
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.message;
      });

      ApiErrorHandler.handle(context, e);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'No se pudo cargar la información de marcaciones';
      });

      ApiErrorHandler.handle(
        context,
        const ValidationException(
          'No se pudo cargar la información de marcaciones',
        ),
      );
    }
  }

  void _changeFilter(String value) {
    setState(() {
      selectedFilter = value;
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Text(
              'Mis marcaciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              _loadMarksData();
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _buildWorkedHours() {
    final hours = me?.todaySummary?.workedHours ?? '';
    return hours.isNotEmpty ? hours : 'Sin horas';
  }

  String _buildTotalMarks() {
    final count = me?.todaySummary?.markingsCount ?? 0;
    return '$count marcaciones';
  }

  String _buildPunctualityText() {
    final count = me?.todaySummary?.markingsCount ?? 0;
    if (count == 0) {
      return 'Sin registros';
    }
    return 'Registrado';
  }

  String _buildShiftName() {
    return me?.currentShift?.name.isNotEmpty == true
        ? me!.currentShift!.name
        : 'Sin turno asignado';
  }

  String _buildShiftStartTime() {
    return me?.currentShift?.startTime.isNotEmpty == true
        ? me!.currentShift!.startTime
        : '--:--';
  }

  String _buildShiftEndTime() {
    return me?.currentShift?.endTime.isNotEmpty == true
        ? me!.currentShift!.endTime
        : '--:--';
  }

  String _buildShiftDays() {
    final workDays = me?.currentShift?.workDays ?? [];
    if (workDays.isEmpty) {
      return 'Sin jornada asignada';
    }
    return workDays.join(', ');
  }

  IconData _iconForHistoryItem(MeAttendanceHistoryItem item) {
    final status = item.status.toLowerCase();

    if (status.contains('out')) {
      return Icons.logout_rounded;
    }

    if (status.contains('break')) {
      return Icons.restaurant_rounded;
    }

    return Icons.login_rounded;
  }

  String _titleForHistoryItem(MeAttendanceHistoryItem item) {
    final status = item.status.toLowerCase();

    if (status == 'checked_in') {
      return 'Entrada';
    }

    if (status == 'checked_out') {
      return 'Salida';
    }

    if (status.contains('break_out')) {
      return 'Inicio colación';
    }

    if (status.contains('break_in')) {
      return 'Término colación';
    }

    return item.status.isNotEmpty ? item.status : 'Marcación';
  }

  String _statusLabelForHistoryItem(MeAttendanceHistoryItem item) {
    final accessPoint = item.accessPointName.trim();
    final direction = item.direction.trim();

    if (accessPoint.isEmpty && direction.isEmpty) {
      return 'Registrada';
    }

    if (accessPoint.isNotEmpty && direction.isNotEmpty) {
      return '$accessPoint · $direction';
    }

    return accessPoint.isNotEmpty ? accessPoint : direction;
  }

  String _timeFromTimestamp(String timestamp) {
    final parsed = DateTime.tryParse(timestamp);
    if (parsed == null) return '--:--';

    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _dateFromTimestamp(String timestamp) {
    final parsed = DateTime.tryParse(timestamp);
    if (parsed == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(parsed.year, parsed.month, parsed.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    return '$day/$month/$year';
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_busy_rounded,
            color: Colors.white,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            'Aún no tienes marcaciones registradas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tus registros aparecerán aquí cuando comiences a marcar asistencia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final history = me?.attendanceHistory ?? [];

    if (history.isEmpty) {
      return _buildEmptyHistory();
    }

    return Column(
      children: history.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MarkRecordItem(
            type: _titleForHistoryItem(item),
            time: _timeFromTimestamp(item.timestamp),
            date: _dateFromTimestamp(item.timestamp),
            status: _statusLabelForHistoryItem(item),
            icon: _iconForHistoryItem(item),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Ocurrió un error inesperado',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 180,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _loadMarksData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF5E1CCF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarksFilterTabs(
            filters: filters,
            selectedFilter: selectedFilter,
            onChanged: _changeFilter,
          ),
          const SizedBox(height: 18),
          MarksSummaryCard(
            title: 'Resumen $selectedFilter',
            workedHours: _buildWorkedHours(),
            punctuality: _buildPunctualityText(),
            totalMarks: _buildTotalMarks(),
          ),
          const SizedBox(height: 16),
          WorkScheduleCard(
            scheduleName: _buildShiftName(),
            entryTime: _buildShiftStartTime(),
            exitTime: _buildShiftEndTime(),
            daysLabel: _buildShiftDays(),
          ),
          const SizedBox(height: 22),
          const Text(
            'Registros',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          _buildHistoryList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyChild;

    if (isLoading) {
      bodyChild = const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else if (errorMessage != null && me == null) {
      bodyChild = _buildErrorState();
    } else {
      bodyChild = _buildContent();
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7A1FEA),
              Color(0xFF9B2CF3),
              Color(0xFFC12DFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: bodyChild,
              ),
            ],
          ),
        ),
      ),
    );
  }
}