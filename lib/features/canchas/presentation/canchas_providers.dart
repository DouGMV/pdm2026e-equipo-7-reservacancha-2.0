import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/filtro_canchas.dart';

class FiltroCanchasNotifier extends Notifier<FiltroCanchas> {
  @override
  FiltroCanchas build() => const FiltroCanchas();

  void seleccionarDeporte(String? deporte) =>
      state = FiltroCanchas(deporte: deporte);
}

/// Filtro del listado del cliente. Es independiente del de administración,
/// así cada pestaña conserva el suyo.
final filtroListadoProvider =
    NotifierProvider<FiltroCanchasNotifier, FiltroCanchas>(
      FiltroCanchasNotifier.new,
    );

/// Listado de canchas. Hace `watch` del filtro, así que al cambiarlo la
/// consulta se repite sola. El reintento automático de Riverpod 3 se desactiva
/// para que el error llegue a la pantalla y el usuario decida cuándo reintentar.
final canchasProvider = FutureProvider<List<Cancha>>((ref) {
  final filtro = ref.watch(filtroListadoProvider);
  return ref
      .watch(canchasRepositoryProvider)
      .obtenerCanchas(deporte: filtro.deporte);
}, retry: (_, _) => null);

/// Una cancha por id, para el detalle. `null` si no existe.
final canchaProvider = FutureProvider.autoDispose.family<Cancha?, String>(
  (ref, id) => ref.watch(canchasRepositoryProvider).obtenerCancha(id),
  retry: (_, _) => null,
);
