import 'package:flutter/material.dart';

import '../core/api_error_handler.dart';
import '../core/auth_exceptions.dart';
import '../models/validate_qr_response.dart';
import '../services/attendance_service.dart';
import '../services/session_service.dart';
import '../widgets/device/access_code_modal.dart';
import '../widgets/device/device_action_button.dart';
import '../widgets/device/device_header.dart';
import '../widgets/device/device_info.dart';
import '../widgets/device/device_logout_button.dart';
import 'card_scanner_screen.dart';
import 'login_screen.dart';
import 'qr_scanner_screen.dart';

class DevicePanelScreen extends StatefulWidget {
  const DevicePanelScreen({super.key});

  @override
  State<DevicePanelScreen> createState() => _DevicePanelScreenState();
}

class _DevicePanelScreenState extends State<DevicePanelScreen> {
  final AttendanceService _attendanceService = const AttendanceService();
  final SessionService _sessionService = const SessionService();

  bool isProcessing = false;
  bool isLoadingDeviceData = true;

  int? deviceId;
  int? accessPointId;
  String username = '';
  String deviceName = 'Dispositivo';
  String direction = '';
  String ipAddress = '192.168.1.10';

  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }

  Future<void> _loadDeviceData() async {
    final savedUsername = await _sessionService.getUsername();
    final savedDeviceId = await _sessionService.getDeviceId();
    final savedAccessPointId = await _sessionService.getAccessPointId();
    final savedDirection = await _sessionService.getDirection();
    final savedDeviceName = await _sessionService.getDeviceName();

    if (!mounted) return;

    setState(() {
      username = savedUsername ?? '';
      deviceId = savedDeviceId;
      accessPointId = savedAccessPointId;
      direction = savedDirection ?? '';
      deviceName = savedDeviceName ?? 'Dispositivo';
      isLoadingDeviceData = false;
    });
  }

  Future<void> _openQrScanner(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(),
      ),
    );

    if (!context.mounted) return;
    if (result == null) return;

    final token = result.toString().trim();
    if (token.isEmpty) return;

    await _validateQrToken(token);
  }

  Future<void> _openAccessCodeModal(BuildContext context) async {
    final code = await showAccessCodeModal(context);

    if (!context.mounted) return;
    if (code == null || code.trim().isEmpty) return;

    await _validateAccessCode(code.trim());
  }

  Future<void> _openCardScanner(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CardScannerScreen(),
      ),
    );

    if (!context.mounted) return;
    if (result == null) return;

    final barcode = result.toString().trim();
    if (barcode.isEmpty) return;

    await _validateBarcode(barcode);
  }

  Future<void> _validateQrToken(String token) async {
    await _processAttendanceValidation(
      request: () => _attendanceService.validateQr(
        token: token,
        accessPointId: accessPointId!,
      ),
      fallbackErrorMessage: 'No se pudo validar el código QR',
    );
  }

  Future<void> _validateAccessCode(String code) async {
    await _processAttendanceValidation(
      request: () => _attendanceService.validateAccessCode(
        accessCode: code,
        accessPointId: accessPointId!,
      ),
      fallbackErrorMessage: 'No se pudo validar el código de acceso',
    );
  }

  Future<void> _validateBarcode(String barcode) async {
    await _processAttendanceValidation(
      request: () => _attendanceService.validateBarcode(
        barcode: barcode,
        accessPointId: accessPointId!,
      ),
      fallbackErrorMessage: 'No se pudo validar la tarjeta',
    );
  }

  Future<void> _processAttendanceValidation({
    required Future<ValidateQrResponse> Function() request,
    required String fallbackErrorMessage,
  }) async {
    if (isProcessing) return;

    if (accessPointId == null) {
      ApiErrorHandler.handle(
        context,
        const ValidationException(
          'No se encontró el access point del dispositivo',
        ),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final ValidateQrResponse response = await request();

      if (!mounted) return;

      final modalTitle = _buildAttendanceMessage(response);
      final modalSubtitle = _buildAttendanceSubtitle(response);
      final modalIcon = _buildAttendanceIcon(response);
      final modalColor = _buildAttendanceColor(response);

      await _showAttendanceResultModal(
        title: modalTitle,
        subtitle: modalSubtitle,
        icon: modalIcon,
        iconColor: modalColor,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ApiErrorHandler.handle(context, e);
    } catch (_) {
      if (!mounted) return;

      ApiErrorHandler.handle(
        context,
        ValidationException(fallbackErrorMessage),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });
    }
  }

  String _buildAttendanceMessage(ValidateQrResponse response) {
    if (response.workOutAt != null && response.workOutAt!.isNotEmpty) {
      return 'Hora de salida registrada';
    }

    if (response.breakInAt != null && response.breakInAt!.isNotEmpty) {
      return 'Término de colación registrado';
    }

    if (response.breakOutAt != null && response.breakOutAt!.isNotEmpty) {
      return 'Inicio de colación registrado';
    }

    if (response.workInAt != null && response.workInAt!.isNotEmpty) {
      return 'Hora de entrada registrada';
    }

    final backendMessage = response.message.trim();
    if (backendMessage.isNotEmpty) {
      return backendMessage;
    }

    return 'Marcación registrada';
  }

  String _buildAttendanceSubtitle(ValidateQrResponse response) {
    if (response.user != null) {
      if (response.user!.firstName.isNotEmpty) {
        return response.user!.firstName;
      }

      if (response.user!.username.isNotEmpty) {
        return response.user!.username;
      }
    }

    if (response.workDate != null && response.workDate!.isNotEmpty) {
      return 'Fecha laboral: ${response.workDate}';
    }

    return 'Registro completado';
  }

  IconData _buildAttendanceIcon(ValidateQrResponse response) {
    if (response.workOutAt != null && response.workOutAt!.isNotEmpty) {
      return Icons.logout_rounded;
    }

    if (response.breakInAt != null && response.breakInAt!.isNotEmpty) {
      return Icons.restaurant_rounded;
    }

    if (response.breakOutAt != null && response.breakOutAt!.isNotEmpty) {
      return Icons.restaurant_menu_rounded;
    }

    if (response.workInAt != null && response.workInAt!.isNotEmpty) {
      return Icons.login_rounded;
    }

    return Icons.check_circle_rounded;
  }

  Color _buildAttendanceColor(ValidateQrResponse response) {
    if (response.workOutAt != null && response.workOutAt!.isNotEmpty) {
      return const Color(0xFF2563EB);
    }

    if (response.breakInAt != null && response.breakInAt!.isNotEmpty) {
      return const Color(0xFF16A34A);
    }

    if (response.breakOutAt != null && response.breakOutAt!.isNotEmpty) {
      return const Color(0xFFF59E0B);
    }

    if (response.workInAt != null && response.workInAt!.isNotEmpty) {
      return const Color(0xFF16A34A);
    }

    return const Color(0xFF16A34A);
  }

  Future<void> _showAttendanceResultModal({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) async {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF2C1757),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6E5A96),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _sessionService.clearSession();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Widget _buildDirectionText() {
    if (direction.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      'Dirección: $direction',
      style: TextStyle(
        color: Colors.white.withOpacity(0.82),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDeviceIdText() {
    if (deviceId == null) {
      return const SizedBox.shrink();
    }

    return Text(
      'Dispositivo ID: $deviceId',
      style: TextStyle(
        color: Colors.white.withOpacity(0.75),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingDeviceData) {
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
          child: const SafeArea(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      );
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 34,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DeviceHeader(
                      title: 'Panel del dispositivo',
                      subtitle: deviceName,
                    ),
                    const SizedBox(height: 16),
                    DeviceInfo(
                      username: username,
                      ipAddress: ipAddress,
                    ),
                    const SizedBox(height: 8),
                    _buildDirectionText(),
                    const SizedBox(height: 4),
                    _buildDeviceIdText(),
                    const SizedBox(height: 28),
                    DeviceActionButton(
                      text: isProcessing ? 'Validando...' : 'Leer QR',
                      onTap: isProcessing
                          ? () {}
                          : () => _openQrScanner(context),
                    ),
                    const SizedBox(height: 14),
                    DeviceActionButton(
                      text: isProcessing ? 'Validando...' : 'Código de acceso',
                      onTap: isProcessing
                          ? () {}
                          : () => _openAccessCodeModal(context),
                    ),
                    const SizedBox(height: 14),
                    DeviceActionButton(
                      text: isProcessing ? 'Validando...' : 'Tarjeta',
                      onTap: isProcessing
                          ? () {}
                          : () => _openCardScanner(context),
                    ),
                    const SizedBox(height: 18),
                    DeviceLogoutButton(
                      text: 'Cerrar sesión',
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}