import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';

/// Rutas que se pueden abrir sin sesión.
const _rutasPublicas = {AppRoutes.login, AppRoutes.registro};

/// Decide a dónde mandar al usuario según la [sesion] y la [ruta] que intenta
/// abrir. Devuelve `null` si puede quedarse.
///
/// Es una función pura para poder probar todas las reglas sin montar la app.
String? calcularRedireccion({
  required AsyncValue<Usuario?> sesion,
  required String ruta,
}) {
  // Mientras no se sabe si hay sesión, no se mueve al usuario.
  if (sesion.isLoading && !sesion.hasValue && !sesion.hasError) return null;

  // Si falló la lectura de la sesión, se trata como si no hubiera sesión.
  final usuario = sesion.hasValue && !sesion.hasError
      ? sesion.requireValue
      : null;
  final esPublica = _rutasPublicas.contains(ruta);

  if (usuario == null) return esPublica ? null : AppRoutes.login;
  if (esPublica) return AppRoutes.canchas;
  if (ruta.startsWith('/admin') && !usuario.esAdmin) return AppRoutes.canchas;
  return null;
}
