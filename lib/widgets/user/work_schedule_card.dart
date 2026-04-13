import 'package:flutter/material.dart';

class WorkScheduleCard extends StatelessWidget {
  final String scheduleName;
  final String entryTime;
  final String exitTime;
  final String daysLabel;

  const WorkScheduleCard({
    super.key,
    required this.scheduleName,
    required this.entryTime,
    required this.exitTime,
    required this.daysLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horario laboral',
            style: TextStyle(
              color: Color(0xFF4D00C9),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            scheduleName,
            style: const TextStyle(
              color: Color(0xFF4D00C9),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ScheduleInfo(
                  label: 'Entrada',
                  value: entryTime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ScheduleInfo(
                  label: 'Salida',
                  value: exitTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ScheduleInfo(
            label: 'Jornada',
            value: daysLabel,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _ScheduleInfo extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;

  const _ScheduleInfo({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4ECFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7B4ACF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4D00C9),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}