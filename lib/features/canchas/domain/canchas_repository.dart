import 'package:reservacancha/features/canchas/domain/cancha.dart';

/// Contrato para obtener las canchas. La implementación vive en `data/`.
abstract interface class CanchasRepository {
  /// Devuelve las canchas del [deporte] indicado, o todas si es `null`.
  Future<List<Cancha>> obtenerCanchas({String? deporte});

  /// La cancha con ese [id], o `null` si no existe.
  Future<Cancha?> obtenerCancha(String id);

  /// Guarda una cancha nueva y devuelve el id que se le asignó (se ignora
  /// `cancha.id`).
  Future<String> crear(Cancha cancha);

  /// Reemplaza los datos de la cancha con el mismo id.
  Future<void> actualizar(Cancha cancha);

  /// Activa o desactiva la cancha sin borrarla. Las inactivas no aparecen
  /// en el listado del cliente.
  Future<void> cambiarActiva(String id, {required bool activa});

  Future<void> eliminar(String id);

  /// Vuelve a guardar la [cancha] idéntica, con el mismo id.
  Future<void> restaurar(Cancha cancha);
}
