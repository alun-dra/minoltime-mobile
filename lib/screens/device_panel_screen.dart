import 'package:flutter/material.dart';
import 'card_scanner_screen.dart';
import 'qr_scanner_screen.dart';
import '../widgets/device/access_code_modal.dart';
import '../widgets/device/device_action_button.dart';
import '../widgets/device/device_header.dart';
import '../widgets/device/device_info.dart';
import '../widgets/device/device_logout_button.dart';

class DevicePanelScreen extends StatelessWidget {
  const DevicePanelScreen({super.key});

  Future<void> _openQrScanner(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(),
      ),
    );

    if (!context.mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR leído: $result'),
        ),
      );
    }
  }

  Future<void> _openCardScanner(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CardScannerScreen(),
      ),
    );

    if (!context.mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarjeta leída: $result'),
        ),
      );
    }
  }

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const DeviceHeader(
                      title: 'Panel del dispositivo',
                      subtitle: 'entrada principal',
                    ),
                    const SizedBox(height: 16),
                    const DeviceInfo(
                      username: 'entradapun',
                      ipAddress: '192.168.1.10',
                    ),
                    const SizedBox(height: 28),
                    DeviceActionButton(
                      text: 'Leer QR',
                      onTap: () => _openQrScanner(context),
                    ),
                    const SizedBox(height: 14),
                    DeviceActionButton(
                      text: 'Código de acceso',
                      onTap: () => showAccessCodeModal(context),
                    ),
                    const SizedBox(height: 14),
                    DeviceActionButton(
                      text: 'Tarjeta',
                      onTap: () => _openCardScanner(context),
                    ),
                    const SizedBox(height: 18),
                    DeviceLogoutButton(
                      text: 'Cerrar sesión',
                      onTap: () {},
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