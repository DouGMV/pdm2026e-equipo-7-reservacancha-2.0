import 'dart:async';

import 'package:reservacancha/core/errors/auth_exception.dart';
import 'package:reservacancha/features/auth/domain/auth_repository.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';

/// Autenticación en memoria mientras no exista la implementación con Firebase.
/// Simula la demora de la red con [Future.delayed].
///
/// Cuentas de ejemplo:
/// - `ana@correo.com` / `secreta1` → cliente
/// - `admin@correo.com` / `admin123` → admin
class AuthRepositoryFake implements AuthRepository {
  AuthRepositoryFake({
    this.demora = const Duration(milliseconds: 800),
    Usuario? sesionInicial,
  }) : _actual = sesionInicial;

  final Duration demora;

  final _cambios = StreamController<Usuario?>.broadcast();
  final Map<String, _Cuenta> _cuentas = {
    for (final cuenta in _cuentasDeEjemplo) cuenta.usuario.email: cuenta,
  };

  Usuario? _actual;
  var _siguienteUid = 1;

  @override
  Stream<Usuario?> cambiosDeSesion() {
    return Stream<Usuario?>.multi((controller) {
      controller.add(_actual);
      final suscripcion = _cambios.stream.listen(controller.add);
      controller.onCancel = () => suscripcion.cancel();
    });
  }

  @override
  Future<Usuario> iniciarSesion({
    required String email,
    required String contrasena,
  }) async {
    await _esperar();
    final cuenta = _cuentas[_normalizar(email)];
    if (cuenta == null || cuenta.contrasena != contrasena) {
      throw const AuthException('Correo o contraseña incorrectos');
    }
    _cambiarSesion(cuenta.usuario);
    return cuenta.usuario;
  }

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String email,
    required String telefono,
    required String contrasena,
  }) async {
    await _esperar();
    final correo = _normalizar(email);
    if (_cuentas.containsKey(correo)) {
      throw const AuthException('Ya existe una cuenta con ese correo');
    }
    final usuario = Usuario(
      uid: 'uid-nuevo-${_siguienteUid++}',
      nombre: nombre.trim(),
      email: correo,
      telefono: telefono.trim(),
      rol: RolUsuario.cliente,
    );
    _cuentas[correo] = _Cuenta(usuario, contrasena);
    _cambiarSesion(usuario);
    return usuario;
  }

  @override
  Future<void> cerrarSesion() async {
    await _esperar();
    _cambiarSesion(null);
  }

  /// Cierra el stream interno; lo llama `authRepositoryProvider` al desecharse.
  void dispose() => _cambios.close();

  Future<void> _esperar() async {
    if (demora > Duration.zero) {
      await Future<void>.delayed(demora);
    }
  }

  void _cambiarSesion(Usuario? usuario) {
    _actual = usuario;
    _cambios.add(usuario);
  }

  static String _normalizar(String email) => email.trim().toLowerCase();
}

class _Cuenta {
  const _Cuenta(this.usuario, this.contrasena);

  final Usuario usuario;
  final String contrasena;
}

const _cuentasDeEjemplo = [
  _Cuenta(
    Usuario(
      uid: 'uid-ana',
      nombre: 'Ana López',
      email: 'ana@correo.com',
      telefono: '55551234',
      rol: RolUsuario.cliente,
    ),
    'secreta1',
  ),
  _Cuenta(
    Usuario(
      uid: 'uid-admin',
      nombre: 'Administrador',
      email: 'admin@correo.com',
      telefono: '55550000',
      rol: RolUsuario.admin,
    ),
    'admin123',
  ),
];
