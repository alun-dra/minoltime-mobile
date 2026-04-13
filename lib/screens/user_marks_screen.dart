import 'package:flutter/material.dart';

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
  String selectedFilter = 'Diario';

  final List<String> filters = ['Diario', 'Semanal', 'Mensual', 'Anual'];

  @override
  Widget build(BuildContext context) {
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
              Padding(
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
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarksFilterTabs(
                        filters: filters,
                        selectedFilter: selectedFilter,
                        onChanged: (value) {
                          setState(() {
                            selectedFilter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      MarksSummaryCard(
                        title: 'Resumen $selectedFilter',
                        workedHours: '08:12 hrs',
                        punctuality: 'A tiempo',
                        totalMarks: '2 marcaciones',
                      ),
                      const SizedBox(height: 16),
                      const WorkScheduleCard(
                        scheduleName: 'Turno administrativo',
                        entryTime: '08:30',
                        exitTime: '17:30',
                        daysLabel: 'Lunes a Viernes',
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
                      const MarkRecordItem(
                        type: 'Entrada',
                        time: '08:27',
                        date: 'Hoy',
                        status: 'A tiempo',
                        icon: Icons.login_rounded,
                      ),
                      const SizedBox(height: 12),
                      const MarkRecordItem(
                        type: 'Salida',
                        time: '17:05',
                        date: 'Hoy',
                        status: 'Pendiente de salida final',
                        icon: Icons.logout_rounded,
                      ),
                      const SizedBox(height: 12),
                      const MarkRecordItem(
                        type: 'Entrada',
                        time: '08:35',
                        date: 'Ayer',
                        status: 'Con atraso',
                        icon: Icons.login_rounded,
                      ),
                      const SizedBox(height: 12),
                      const MarkRecordItem(
                        type: 'Salida',
                        time: '17:31',
                        date: 'Ayer',
                        status: 'Completada',
                        icon: Icons.logout_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}