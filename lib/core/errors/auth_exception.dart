/// Error de autenticación con un mensaje en español listo para mostrarse en
/// pantalla (ver docs/ARQUITECTURA.md: errores propios en `core/errors`).
class AuthException implements Exception {
  const AuthException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
