import 'package:flutter/material.dart';

import '../core/api_error_handler.dart';
import '../core/auth_exceptions.dart';
import '../models/me_response.dart';
import '../services/user_service.dart';

class UserAccessCodeScreen extends StatefulWidget {
  const UserAccessCodeScreen({super.key});

  @override
  State<UserAccessCodeScreen> createState() => _UserAccessCodeScreenState();
}

class _UserAccessCodeScreenState extends State<UserAccessCodeScreen> {
  final UserService _userService = const UserService();

  MeResponse? user;
  String accessCode = '';
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAccessCode();
  }

  Future<void> _loadAccessCode() async {
    try {
      final meResponse = await _userService.getMe();
      final accessCodeResponse =
          await _userService.getAccessCode(meResponse.id);

      if (!mounted) return;

      setState(() {
        user = meResponse;
        accessCode = accessCodeResponse.accessCode;
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
        errorMessage = 'No se pudo cargar el código de acceso';
      });

      ApiErrorHandler.handle(
        context,
        const ValidationException('No se pudo cargar el código de acceso'),
      );
    }
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
            'Código de acceso',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: isLoading
              ? null
              : () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _loadAccessCode();
                },
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
              _loadAccessCode();
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

  Widget _buildAccessCodeContent() {
    return Column(
      children: [
        Text(
          'Usa este código para registrar tu marcación manualmente',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 36),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.password_rounded,
                size: 52,
                color: Color(0xFF4D00C9),
              ),
              const SizedBox(height: 18),
              Text(
                accessCode.isNotEmpty ? accessCode : 'Sin código',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF4D00C9),
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Este código es personal y debe ser utilizado solo por ti.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.78),
            fontSize: 13,
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
    } else if (errorMessage != null || user == null) {
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildAccessCodeContent(),
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