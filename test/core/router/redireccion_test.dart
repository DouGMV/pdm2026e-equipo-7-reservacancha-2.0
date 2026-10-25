import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/core/router/redireccion.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';

const _cliente = Usuario(
  uid: 'uid-ana',
  nombre: 'Ana López',
  email: 'ana@correo.com',
  telefono: '55551234',
  rol: RolUsuario.cliente,
);

const _admin = Usuario(
  uid: 'uid-admin',
  nombre: 'Administrador',
  email: 'admin@correo.com',
  telefono: '55550000',
  rol: RolUsuario.admin,
);

String? _redirigir(AsyncValue<Usuario?> sesion, String ruta) =>
    calcularRedireccion(sesion: sesion, ruta: ruta);

void main() {
  const sinSesion = AsyncData<Usuario?>(null);
  const conCliente = AsyncData<Usuario?>(_cliente);
  const conAdmin = AsyncData<Usuario?>(_admin);

  group('mientras se carga la sesión', () {
    test('no mueve al usuario', () {
      const cargando = AsyncLoading<Usuario?>();

      expect(_redirigir(cargando, AppRoutes.login), isNull);
      expect(_redirigir(cargando, AppRoutes.canchas), isNull);
    });
  });

  group('sin sesión', () {
    test('las rutas públicas se pueden abrir', () {
      expect(_redirigir(sinSesion, AppRoutes.login), isNull);
      expect(_redirigir(sinSesion, AppRoutes.registro), isNull);
    });

    test('las rutas privadas mandan al login', () {
      expect(_redirigir(sinSesion, AppRoutes.canchas), AppRoutes.login);
      expect(_redirigir(sinSesion, '/cancha/cancha-1'), AppRoutes.login);
      expect(
        _redirigir(sinSesion, AppRoutes.confirmarReserva),
        AppRoutes.login,
      );
      expect(_redirigir(sinSesion, AppRoutes.adminCanchas), AppRoutes.login);
    });

    test('si falla la lectura de la sesión se trata como sin sesión', () {
      final error = AsyncError<Usuario?>(
        Exception('sin red'),
        StackTrace.empty,
      );

      expect(_redirigir(error, AppRoutes.canchas), AppRoutes.login);
      expect(_redirigir(error, AppRoutes.login), isNull);
    });
  });

  group('con sesión de cliente', () {
    test('el login y el registro mandan al inicio', () {
      expect(_redirigir(conCliente, AppRoutes.login), AppRoutes.canchas);
      expect(_redirigir(conCliente, AppRoutes.registro), AppRoutes.canchas);
    });

    test('puede abrir las rutas de cliente', () {
      expect(_redirigir(conCliente, AppRoutes.canchas), isNull);
      expect(_redirigir(conCliente, '/cancha/cancha-1'), isNull);
      expect(_redirigir(conCliente, AppRoutes.confirmarReserva), isNull);
    });

    test('las rutas de admin mandan al inicio', () {
      expect(_redirigir(conCliente, AppRoutes.adminCanchas), AppRoutes.canchas);
      expect(
        _redirigir(conCliente, AppRoutes.adminReservas),
        AppRoutes.canchas,
      );
    });
  });

  group('con sesión de admin', () {
    test('puede abrir las rutas de admin', () {
      expect(_redirigir(conAdmin, AppRoutes.adminCanchas), isNull);
      expect(_redirigir(conAdmin, AppRoutes.adminReservas), isNull);
    });

    test('también puede abrir las rutas de cliente', () {
      expect(_redirigir(conAdmin, AppRoutes.canchas), isNull);
    });
  });
}
