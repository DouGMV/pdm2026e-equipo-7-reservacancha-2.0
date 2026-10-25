/// Rol del usuario guardado en `usuarios/{uid}` (ver docs/ARQUITECTURA.md).
enum RolUsuario { cliente, admin }

/// Usuario con sesión iniciada.
class Usuario {
  const Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rol,
  });

  final String uid;
  final String nombre;
  final String email;
  final String telefono;
  final RolUsuario rol;

  bool get esAdmin => rol == RolUsuario.admin;
}
