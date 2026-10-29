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
///
/// Regla del Lab S16: después de crear, editar, desactivar o restaurar, la
/// lista se refresca **invalidando** los providers, nunca agregando a mano.
class AdminCanchasNotifier extends AsyncNotifier<List<Cancha>> {
  @override
  Future<List<Cancha>> build() {
    final filtro = ref.watch(filtroCanchasProvider);
    return ref
        .watch(canchasRepositoryProvider)
        .obtenerCanchas(deporte: filtro.deporte);
  }

  /// Borra primero en el repositorio. Si la cancha está en uso, el
  /// repositorio lanza `CanchaEnUsoException`: el error llega tal cual a la
  /// pantalla (que muestra su `mensaje` y ofrece Desactivar) y la lista no
  /// cambia.
  Future<void> eliminar(Cancha cancha) async {
    await ref.read(canchasRepositoryProvider).eliminar(cancha.id);
    if (!ref.mounted) return;
    ref.invalidate(canchaProvider(cancha.id));
    _actualizarListadoCliente();
  }

  /// Saca de la lista la fila que el usuario acaba de deslizar, ya borrada en
  /// el repositorio. Es la única excepción a "refrescar invalidando": el
  /// `Dismissible` exige que la fila salga del árbol en ese mismo frame, y
  /// una invalidación mostraría la carga y nunca el SnackBar de Deshacer. No
  /// agrega ni cambia datos: solo quita lo que la base ya no tiene.
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
    ref
      ..invalidateSelf()
      ..invalidate(canchaProvider(cancha.id));
    _actualizarListadoCliente();
  }

  /// Desactivar es "archivar": la cancha deja de verse en el listado del
  /// cliente y pasa a Archivadas, sin perder sus reservas.
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

/// Canchas de administración separadas para la pantalla: las activas arriba
/// y las desactivadas en "Archivadas".
typedef CanchasAgrupadas = ({List<Cancha> activas, List<Cancha> archivadas});

/// Deriva de [adminCanchasProvider]: cuando la lista se invalida, esto se
/// recalcula solo. Conserva la carga y el error de la lista original.
final canchasAgrupadasProvider = Provider<AsyncValue<CanchasAgrupadas>>(
  (ref) => ref
      .watch(adminCanchasProvider)
      .whenData(
        (canchas) => (
          activas: [
            for (final cancha in canchas)
              if (cancha.activa) cancha,
          ],
          archivadas: [
            for (final cancha in canchas)
              if (!cancha.activa) cancha,
          ],
        ),
      ),
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

  /// Crea la cancha si [nueva]; si no, la actualiza (el id no cambia).
  ///
  /// Si el nombre ya existe, el repositorio lanza `CanchaDuplicadaException`:
  /// el error queda en el estado para que el formulario muestre su `mensaje`
  /// y no se cierre, y no se refresca nada porque nada cambió.
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
    if (!resultado.hasError) {
      ref
        ..invalidate(adminCanchasProvider)
        ..invalidate(canchasProvider);
      // Una cancha nueva todavía no tiene detalle abierto que refrescar.
      if (!nueva) ref.invalidate(canchaProvider(cancha.id));
    }
    state = resultado;
  }
}
