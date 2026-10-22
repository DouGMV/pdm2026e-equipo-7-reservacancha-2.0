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

final filtroCanchasProvider =
    NotifierProvider<FiltroCanchasNotifier, FiltroCanchas>(
      FiltroCanchasNotifier.new,
    );

/// Canchas de la pantalla de administración. Hace `watch` del filtro, así que
/// al cambiarlo la consulta se repite sola.
class AdminCanchasNotifier extends AsyncNotifier<List<Cancha>> {
  @override
  Future<List<Cancha>> build() {
    final filtro = ref.watch(filtroCanchasProvider);
    return ref
        .watch(canchasRepositoryProvider)
        .obtenerCanchas(deporte: filtro.deporte);
  }

  /// Borra primero en el repositorio. Si falla, la excepción llega a la
  /// pantalla y la lista no cambia.
  Future<void> eliminar(Cancha cancha) =>
      ref.read(canchasRepositoryProvider).eliminar(cancha.id);

  /// Quita la cancha de la lista sin volver a consultar. El `Dismissible`
  /// necesita que la fila salga del árbol en cuanto termina de deslizarse.
  void quitarDeLaLista(Cancha cancha) {
    final canchas = state.value;
    if (canchas == null) return;
    state = AsyncData([
      for (final c in canchas)
        if (c.id != cancha.id) c,
    ]);
  }

  Future<void> restaurar(Cancha cancha) async {
    await ref.read(canchasRepositoryProvider).restaurar(cancha);
    if (ref.mounted) ref.invalidateSelf();
  }
}

final adminCanchasProvider =
    AsyncNotifierProvider<AdminCanchasNotifier, List<Cancha>>(
      AdminCanchasNotifier.new,
      retry: (_, _) => null,
    );
