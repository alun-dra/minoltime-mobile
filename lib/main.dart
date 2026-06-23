import 'package:flutter/material.dart';

import 'core/app_navigator.dart';
import 'core/offline_sync_manager.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  OfflineSyncManager().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MinolTime',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.navigatorKey,
      scaffoldMessengerKey: AppNavigator.scaffoldMessengerKey,
      home: const SplashScreen(),
    );
  }
}