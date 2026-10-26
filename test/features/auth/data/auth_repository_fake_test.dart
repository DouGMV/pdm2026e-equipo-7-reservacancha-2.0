import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/errors/auth_exception.dart';
import 'package:reservacancha/features/auth/data/auth_repository_fake.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';

void main() {
  late AuthRepositoryFake repositorio;

  setUp(() => repositorio = AuthRepositoryFake(demora: Duration.zero));
  tearDown(() => repositorio.dispose());

  test('emite null al suscribirse cuando no hay sesión', () async {
    expect(await repositorio.cambiosDeSesion().first, isNull);
  });

  test('inicia sesión con una cuenta de ejemplo y emite el usuario', () async {
    final usuario = await repositorio.iniciarSesion(
      email: ' ANA@correo.com ',
      contrasena: 'secreta1',
    );

    expect(usuario.email, 'ana@correo.com');
    expect(usuario.rol, RolUsuario.cliente);
    expect((await repositorio.cambiosDeSesion().first)?.uid, 'uid-ana');
  });

  test('rechaza una contraseña incorrecta', () {
    expect(
      repositorio.iniciarSesion(email: 'ana@correo.com', contrasena: 'otra12'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.mensaje,
          'mensaje',
          'Correo o contraseña incorrectos',
        ),
      ),
    );
  });

  test('la cuenta admin tiene rol admin', () async {
    final usuario = await repositorio.iniciarSesion(
      email: 'admin@correo.com',
      contrasena: 'admin123',
    );

    expect(usuario.esAdmin, isTrue);
  });

  test('registrar crea un cliente y deja la sesión iniciada', () async {
    final usuario = await repositorio.registrar(
      nombre: 'Luis Pérez',
      email: 'luis@correo.com',
      telefono: '55559876',
      contrasena: 'secreta1',
    );

    expect(usuario.rol, RolUsuario.cliente);
    expect(
      (await repositorio.cambiosDeSesion().first)?.email,
      'luis@correo.com',
    );
  });

  test('no permite registrar un correo existente', () {
    expect(
      repositorio.registrar(
        nombre: 'Otra Ana',
        email: 'ana@correo.com',
        telefono: '55551111',
        contrasena: 'secreta1',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('cerrar sesión emite null a quien ya escuchaba', () async {
    await repositorio.iniciarSesion(
      email: 'ana@correo.com',
      contrasena: 'secreta1',
    );
    final emisiones = repositorio.cambiosDeSesion().take(2).toList();

    await repositorio.cerrarSesion();

    final valores = await emisiones;
    expect(valores.first?.uid, 'uid-ana');
    expect(valores.last, isNull);
  });
}
