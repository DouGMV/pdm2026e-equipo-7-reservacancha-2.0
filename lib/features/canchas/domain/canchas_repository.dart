import 'package:reservacancha/features/canchas/domain/cancha.dart';

/// Contrato para obtener las canchas. La implementación vive en `data/`.
abstract interface class CanchasRepository {
  /// Devuelve las canchas del [deporte] indicado, o todas si es `null`.
  Future<List<Cancha>> obtenerCanchas({String? deporte});

  /// La cancha con ese [id], o `null` si no existe.
  Future<Cancha?> obtenerCancha(String id);

  Future<void> eliminar(String id);

  /// Vuelve a guardar la [cancha] idéntica, con el mismo id.
  Future<void> restaurar(Cancha cancha);
}
