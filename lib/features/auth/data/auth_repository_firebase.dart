import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:reservacancha/core/constants/firestore_collections.dart';
import 'package:reservacancha/core/errors/auth_exception.dart';
import 'package:reservacancha/features/auth/data/usuario_model.dart';
import 'package:reservacancha/features/auth/domain/auth_repository.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';

/// Autenticación con Firebase Auth. El rol y los datos del perfil viven en
/// `usuarios/{uid}` de Firestore.
class AuthRepositoryFirebase implements AuthRepository {
  AuthRepositoryFirebase(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _firestore.collection(FirestoreCollections.usuarios);

  @override
  Stream<Usuario?> cambiosDeSesion() {
    return _auth.authStateChanges().asyncMap(
      (usuario) => usuario == null ? null : _leerUsuario(usuario),
    );
  }

  @override
  Future<Usuario> iniciarSesion({
    required String email,
    required String contrasena,
  }) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: contrasena,
      );
      return await _leerUsuario(credencial.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(mensajeDeErrorAuth(e.code));
    }
  }

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String email,
    required String telefono,
    required String contrasena,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: contrasena,
      );
      final usuario = Usuario(
        uid: credencial.user!.uid,
        nombre: nombre.trim(),
        email: email.trim(),
        telefono: telefono.trim(),
        rol: RolUsuario.cliente,
      );
      // Todo registro nuevo es cliente (lo exige firestore.rules).
      await _usuarios.doc(usuario.uid).set({
        ...UsuarioModel.toMap(usuario),
        'creadoEn': FieldValue.serverTimestamp(),
      });
      return usuario;
    } on FirebaseAuthException catch (e) {
      throw AuthException(mensajeDeErrorAuth(e.code));
    }
  }

  @override
  Future<void> cerrarSesion() => _auth.signOut();

  Future<Usuario> _leerUsuario(User usuario) async {
    final datos = (await _usuarios.doc(usuario.uid).get()).data();
    if (datos == null) {
      // Cuenta sin documento (por ejemplo, creada desde la consola): cliente.
      return Usuario(
        uid: usuario.uid,
        nombre: usuario.displayName ?? '',
        email: usuario.email ?? '',
        telefono: '',
        rol: RolUsuario.cliente,
      );
    }
    return UsuarioModel.fromMap(usuario.uid, datos);
  }
}

/// Traduce los códigos de error de Firebase Auth a mensajes en español.
/// Nunca se muestra el error crudo de Firebase.
String mensajeDeErrorAuth(String codigo) => switch (codigo) {
  'invalid-credential' ||
  'wrong-password' ||
  'user-not-found' => 'Correo o contraseña incorrectos',
  'invalid-email' => 'El correo no es válido',
  'email-already-in-use' => 'Ya existe una cuenta con ese correo',
  'weak-password' => 'La contraseña es muy débil (mínimo 6 caracteres)',
  'user-disabled' => 'Esta cuenta está deshabilitada',
  'too-many-requests' => 'Demasiados intentos. Espera unos minutos',
  'network-request-failed' => 'Sin conexión. Revisa tu internet',
  _ => 'No pudimos completar la operación. Intenta de nuevo',
};
