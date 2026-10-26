import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/auth/data/auth_repository_provider.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';

/// Usuario con sesión (`null` si no hay). El router lo escucha para redirigir
/// y cualquier pantalla puede leer el rol desde aquí.
final sesionProvider = StreamProvider<Usuario?>(
  (ref) => ref.watch(authRepositoryProvider).cambiosDeSesion(),
);

/// Acciones de autenticación. Su estado indica a las pantallas si hay una
/// operación en curso (`isLoading`) o si falló (`hasError`).
///
/// No navega: al cambiar la sesión, el `redirect` del router decide a dónde ir.
final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> iniciarSesion({
    required String email,
    required String contrasena,
  }) {
    return _ejecutar(
      () => ref
          .read(authRepositoryProvider)
          .iniciarSesion(email: email, contrasena: contrasena),
    );
  }

  Future<void> registrar({
    required String nombre,
    required String email,
    required String telefono,
    required String contrasena,
  }) {
    return _ejecutar(
      () => ref
          .read(authRepositoryProvider)
          .registrar(
            nombre: nombre,
            email: email,
            telefono: telefono,
            contrasena: contrasena,
          ),
    );
  }

  Future<void> cerrarSesion() {
    return _ejecutar(() => ref.read(authRepositoryProvider).cerrarSesion());
  }

  Future<void> _ejecutar(Future<Object?> Function() accion) async {
    state = const AsyncLoading();
    final resultado = await AsyncValue.guard<void>(() async {
      await accion();
    });
    if (ref.mounted) state = resultado;
  }
}
