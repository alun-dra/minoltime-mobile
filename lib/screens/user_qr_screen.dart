import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/api_error_handler.dart';
import '../core/auth_exceptions.dart';
import '../models/local_qr_session.dart';
import '../models/me_response.dart';
import '../models/qr_session_response.dart';
import '../services/qr_service.dart';
import '../services/qr_session_service.dart';
import '../services/user_service.dart';

class UserQrScreen extends StatefulWidget {
  const UserQrScreen({super.key});

  @override
  State<UserQrScreen> createState() => _UserQrScreenState();
}

class _UserQrScreenState extends State<UserQrScreen> {
  final UserService _userService = const UserService();
  final QrService _qrService = const QrService();
  final QrSessionService _qrSessionService = const QrSessionService();

  MeResponse? user;
  LocalQrSession? qrSession;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQr();
  }

  Future<void> _loadQr({bool forceRefresh = false}) async {
    try {
      final me = await _userService.getMe();

      LocalQrSession? localSession;

      if (!forceRefresh) {
        localSession = await _qrSessionService.getQrSession();
      }

      if (localSession == null) {
        final QrSessionResponse backendQr = await _qrService.generateUserQr(
          userId: me.id,
        );

        await _qrSessionService.saveQrSession(backendQr);
        localSession = await _qrSessionService.getQrSession();
      }

      if (!mounted) return;

      setState(() {
        user = me;
        qrSession = localSession;
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
        errorMessage = 'No se pudo generar el código QR';
      });

      ApiErrorHandler.handle(
        context,
        const ValidationException('No se pudo generar el código QR'),
      );
    }
  }

  Future<void> _refreshQr() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    await _qrSessionService.clearQrSession();
    await _loadQr(forceRefresh: true);
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
            'Mi código QR',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: isLoading ? null : _refreshQr,
          icon: const Icon(
            Icons.refresh_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
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
              _loadQr();
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
    );
  }

  Widget _buildQrContent() {
    final token = qrSession?.token ?? '';

    return Column(
      children: [
        Text(
          user?.fullName ?? 'Usuario',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Muestra este código para registrar tu marcación',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: QrImageView(
            data: token,
            version: QrVersions.auto,
            size: 240,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Expira en ${qrSession?.remainingSeconds ?? 0} segundos',
          style: TextStyle(
            color: Colors.white.withOpacity(0.80),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyChild;

    if (isLoading) {
      bodyChild = const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else if (errorMessage != null || qrSession == null) {
      bodyChild = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildErrorState(),
        ),
      );
    } else {
      bodyChild = Center(
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
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildQrContent(),
              ],
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
          child: bodyChild,
        ),
      ),
    );
  }
}