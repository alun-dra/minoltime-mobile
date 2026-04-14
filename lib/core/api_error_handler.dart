import 'package:flutter/material.dart';

import 'auth_exceptions.dart';

class ApiErrorHandler {
  const ApiErrorHandler._();

  static void handle(BuildContext context, dynamic error) {
    if (!context.mounted) return;

    String message;

    if (error is AuthException) {
      message = error.message;
    } else {
      message = 'Ocurrió un error inesperado';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}