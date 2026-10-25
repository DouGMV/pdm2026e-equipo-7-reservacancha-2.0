import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/canchas/data/canchas_de_ejemplo.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/filtro_canchas.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_providers.dart';

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
  Future<void> eliminar(Cancha cancha) async {
    await ref.read(canchasRepositoryProvider).eliminar(cancha.id);
    _actualizarListadoCliente();
  }

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
    if (!ref.mounted) return;
    ref.invalidateSelf();
    _actualizarListadoCliente();
  }

  Future<void> cambiarActiva(Cancha cancha, {required bool activa}) async {
    await ref
        .read(canchasRepositoryProvider)
        .cambiarActiva(cancha.id, activa: activa);
    if (!ref.mounted) return;
    ref
      ..invalidateSelf()
      ..invalidate(canchaProvider(cancha.id));
    _actualizarListadoCliente();
  }

  /// Guarda las canchas de ejemplo (issue #48): así un proyecto de Firebase
  /// nuevo tiene datos para probar sin escribirlos a mano en la consola.
  Future<void> cargarEjemplos() async {
    final repositorio = ref.read(canchasRepositoryProvider);
    for (final cancha in canchasDeEjemplo) {
      await repositorio.crear(cancha);
    }
    if (!ref.mounted) return;
    ref.invalidateSelf();
    _actualizarListadoCliente();
  }

  /// La pestaña Canchas sigue viva en el `IndexedStack` de la barra: sin
  /// esto mostraría la lista anterior al volver a ella.
  void _actualizarListadoCliente() {
    if (ref.mounted) ref.invalidate(canchasProvider);
  }
}

final adminCanchasProvider =
    AsyncNotifierProvider<AdminCanchasNotifier, List<Cancha>>(
      AdminCanchasNotifier.new,
      retry: (_, _) => null,
    );

/// Guarda el formulario de una cancha. Su estado indica si hay una operación
/// en curso (`isLoading`) o si falló (`hasError`).
final canchaFormControllerProvider =
    AsyncNotifierProvider.autoDispose<CanchaFormController, void>(
      CanchaFormController.new,
    );

class CanchaFormController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Crea la cancha si [nueva]; si no, la actualiza.
  Future<void> guardar(Cancha cancha, {required bool nueva}) async {
    state = const AsyncLoading();
    final resultado = await AsyncValue.guard<void>(() async {
      final repositorio = ref.read(canchasRepositoryProvider);
      if (nueva) {
        await repositorio.crear(cancha);
      } else {
        await repositorio.actualizar(cancha);
      }
    });
    if (!ref.mounted) return;
    ref
      ..invalidate(adminCanchasProvider)
      ..invalidate(canchasProvider)
      ..invalidate(canchaProvider(cancha.id));
    state = resultado;
  }
}
