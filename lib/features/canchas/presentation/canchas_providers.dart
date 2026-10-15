import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reservacancha/features/canchas/data/cancha_repository_impl.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/cancha_repository.dart';

/// Implementación del repositorio; en las pruebas se reemplaza con un override.
final canchaRepositoryProvider = Provider<CanchaRepository>(
  (ref) => CanchaRepositoryImpl(),
);

/// Listado de canchas expuesto a la pantalla como [AsyncValue].
///
/// El reintento automático de Riverpod 3 queda desactivado (`retry: null`)
/// para que un error se quede en pantalla hasta que el usuario toque
/// Reintentar (lab S14, req. 5).
final canchasProvider = FutureProvider<List<Cancha>>((ref) {
  return ref.watch(canchaRepositoryProvider).obtenerCanchas();
}, retry: null);
