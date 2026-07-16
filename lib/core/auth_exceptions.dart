class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super('Usuario o contraseña incorrectos');
}

class SessionExpiredException extends AuthException {
  const SessionExpiredException()
      : super('Tu sesión ha expirado. Inicia sesión nuevamente');
}

class ServerUnavailableException extends AuthException {
  const ServerUnavailableException()
      : super('El servidor no está disponible en este momento');
}

class NetworkException extends AuthException {
  const NetworkException()
      : super('No se pudo conectar con el servidor');
}

class RequestTimeoutException extends AuthException {
  const RequestTimeoutException()
      : super('La solicitud tardó demasiado. Intenta nuevamente');
}

class ValidationException extends AuthException {
  const ValidationException(super.message);
}

class GenericServerException extends AuthException {
  const GenericServerException()
      : super('Ocurrió un error interno en el servidor');
}

class FraudSuspicionException extends AuthException {
  const FraudSuspicionException()
      : super(
          'Se detectó una marcación reciente en otra sucursal. Intenta nuevamente en unos minutos.',
        );
}

class RateLimitException extends AuthException {
  final int? retryAfterSeconds;

  const RateLimitException([this.retryAfterSeconds])
      : super('Demasiados intentos. Intenta nuevamente en unos segundos.');
}