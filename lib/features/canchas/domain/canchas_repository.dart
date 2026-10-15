import 'package:reservacancha/features/canchas/domain/cancha.dart';

/// Contrato para obtener las canchas. La implementación vive en `data/`.
abstract interface class CanchasRepository {
  Future<List<Cancha>> obtenerCanchas();
}
