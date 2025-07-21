import 'package:firebase_auth/firebase_auth.dart';

enum AuthResultType { normal, unverified, error }

class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? errorCode;
  final AuthResultType type;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.errorCode,
    this.type = AuthResultType.normal,
  });

  // Factory constructors for common scenarios
  factory AuthResult.success({AuthResultType type = AuthResultType.normal}) {
    return AuthResult(success: true, type: type);
  }

  factory AuthResult.failure({
    required String errorMessage,
    String? errorCode,
  }) {
    return AuthResult(
      success: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
      type: AuthResultType.error,
    );
  }

  // Special case for unverified users (success but needs verification)
  factory AuthResult.unverified() {
    return const AuthResult(success: true, type: AuthResultType.unverified);
  }

  // Factory constructor for Firebase Auth exceptions
  factory AuthResult.fromFirebaseException(dynamic exception) {
    if (exception is FirebaseAuthException) {
      String message;
      switch (exception.code) {
        case 'email-already-in-use':
          message = 'Este correo electrónico ya está registrado en el sistema';
          break;
        case 'weak-password':
          message =
              'La contraseña es muy débil. Debe tener al menos 6 caracteres';
          break;
        case 'invalid-email':
          message = 'El correo electrónico no es válido';
          break;
        case 'operation-not-allowed':
          message = 'La operación no está permitida';
          break;
        case 'user-disabled':
          message = 'Esta cuenta ha sido deshabilitada';
          break;
        case 'user-not-found':
          message = 'No se encontró una cuenta con este correo electrónico';
          break;
        case 'wrong-password':
          message = 'Contraseña incorrecta';
          break;
        case 'invalid-credential':
          message =
              'Su correo y contraseña no coinciden. Por favor, verifique y vuelva a intentarlo';
          break;
        case 'too-many-requests':
          message = 'Demasiados intentos fallidos. Intente más tarde';
          break;
        case 'network-request-failed':
          message = 'Error de conexión. Verifique su conexión a internet';
          break;
        default:
          message =
              'Error de autenticación: ${exception.message ?? 'Error desconocido'}';
      }
      return AuthResult.failure(
        errorMessage: message,
        errorCode: exception.code,
      );
    }

    return AuthResult.failure(
      errorMessage: 'Error desconocido: ${exception.toString()}',
    );
  }
}
