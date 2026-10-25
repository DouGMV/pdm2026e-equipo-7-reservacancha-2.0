import 'package:reservacancha/features/auth/domain/usuario.dart';

/// Contrato de autenticación. La implementación vive en `data/`:
/// por ahora `AuthRepositoryFake`; la de Firebase la hace la capa de datos.
///
/// Los errores esperados (credenciales incorrectas, correo ya registrado) se
/// lanzan como `AuthException` con el mensaje en español.
abstract interface class AuthRepository {
  /// Emite el usuario con sesión apenas alguien se suscribe y luego cada vez
  /// que la sesión cambia; `null` cuando no hay sesión.
  ///
  /// Con Firebase: `authStateChanges()` + leer `usuarios/{uid}` para el rol.
  Stream<Usuario?> cambiosDeSesion();

  Future<Usuario> iniciarSesion({
    required String email,
    required String contrasena,
  });

  /// Crea la cuenta con rol `cliente` y deja la sesión iniciada.
  Future<Usuario> registrar({
    required String nombre,
    required String email,
    required String telefono,
    required String contrasena,
  });

  Future<void> cerrarSesion();
}
