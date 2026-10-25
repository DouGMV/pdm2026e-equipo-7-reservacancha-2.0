import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reservacancha/core/errors/auth_exception.dart';
import 'package:reservacancha/features/auth/data/auth_repository_firebase.dart';
import 'package:reservacancha/features/auth/data/usuario_model.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';

class _FirebaseAuthMock extends Mock implements FirebaseAuth {}

class _UserCredentialMock extends Mock implements UserCredential {}

class _UserMock extends Mock implements User {}

void main() {
  late _FirebaseAuthMock auth;
  late FakeFirebaseFirestore firestore;
  late AuthRepositoryFirebase repositorio;

  setUp(() {
    auth = _FirebaseAuthMock();
    firestore = FakeFirebaseFirestore();
    repositorio = AuthRepositoryFirebase(auth, firestore);
  });

  /// Firebase Auth responde con un usuario [uid] al iniciar sesión o
  /// registrarse.
  void simularUsuario(String uid) {
    final usuario = _UserMock();
    when(() => usuario.uid).thenReturn(uid);
    when(() => usuario.email).thenReturn('$uid@correo.com');
    when(() => usuario.displayName).thenReturn(null);
    final credencial = _UserCredentialMock();
    when(() => credencial.user).thenReturn(usuario);
    when(
      () => auth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => credencial);
    when(
      () => auth.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => credencial);
  }

  test('iniciar sesión lee el rol de usuarios/{uid}', () async {
    simularUsuario('admin1');
    await firestore.collection('usuarios').doc('admin1').set({
      'nombre': 'Admin',
      'email': 'admin1@correo.com',
      'telefono': '55555555',
      'rol': 'admin',
    });

    final usuario = await repositorio.iniciarSesion(
      email: ' admin1@correo.com ',
      contrasena: 'secreta',
    );

    expect(usuario.esAdmin, isTrue);
    expect(usuario.nombre, 'Admin');
    verify(
      () => auth.signInWithEmailAndPassword(
        email: 'admin1@correo.com',
        password: 'secreta',
      ),
    ).called(1);
  });

  test('una cuenta sin documento entra como cliente', () async {
    simularUsuario('nuevo');

    final usuario = await repositorio.iniciarSesion(
      email: 'nuevo@correo.com',
      contrasena: 'secreta',
    );

    expect(usuario.rol, RolUsuario.cliente);
    expect(usuario.email, 'nuevo@correo.com');
  });

  test('registrar guarda el perfil como cliente', () async {
    simularUsuario('ana');

    await repositorio.registrar(
      nombre: 'Ana',
      email: 'ana@correo.com',
      telefono: '12345678',
      contrasena: 'secreta1',
    );

    final doc = await firestore.collection('usuarios').doc('ana').get();
    expect(doc.data()!['rol'], 'cliente');
    expect(doc.data()!['telefono'], '12345678');
    expect(doc.data()!['creadoEn'], isNotNull);
  });

  test('un error de Firebase se traduce al español', () async {
    when(
      () => auth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

    await expectLater(
      repositorio.iniciarSesion(email: 'a@b.com', contrasena: 'x'),
      throwsA(
        isA<AuthException>().having(
          (e) => e.mensaje,
          'mensaje',
          'Correo o contraseña incorrectos',
        ),
      ),
    );
  });

  test('un código desconocido usa el mensaje genérico', () {
    expect(
      mensajeDeErrorAuth('email-already-in-use'),
      'Ya existe una cuenta con ese correo',
    );
    expect(
      mensajeDeErrorAuth('algo-raro'),
      'No pudimos completar la operación. Intenta de nuevo',
    );
  });

  test('UsuarioModel conserva los datos al ir y volver de Firestore', () {
    const usuario = Usuario(
      uid: 'u1',
      nombre: 'Ana',
      email: 'ana@correo.com',
      telefono: '1234',
      rol: RolUsuario.admin,
    );

    final copia = UsuarioModel.fromMap('u1', UsuarioModel.toMap(usuario));

    expect(copia.rol, RolUsuario.admin);
    expect(copia.telefono, '1234');
  });
}
