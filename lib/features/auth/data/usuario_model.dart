import 'package:reservacancha/features/auth/domain/usuario.dart';

/// Conversión entre [Usuario] y el documento `usuarios/{uid}` de Firestore.
abstract final class UsuarioModel {
  static Usuario fromMap(String uid, Map<String, dynamic> datos) {
    return Usuario(
      uid: uid,
      nombre: datos['nombre'] as String? ?? '',
      email: datos['email'] as String? ?? '',
      telefono: datos['telefono'] as String? ?? '',
      rol: datos['rol'] == 'admin' ? RolUsuario.admin : RolUsuario.cliente,
    );
  }

  /// Sin `creadoEn`: lo agrega el repositorio con la hora del servidor.
  static Map<String, Object?> toMap(Usuario usuario) {
    return {
      'nombre': usuario.nombre,
      'email': usuario.email,
      'telefono': usuario.telefono,
      'rol': usuario.rol.name,
    };
  }
}
