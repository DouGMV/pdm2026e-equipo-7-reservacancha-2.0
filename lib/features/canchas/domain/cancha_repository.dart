import 'package:reservacancha/features/canchas/domain/cancha.dart';

/// Contrato del repositorio de canchas (capa domain).
///
/// La implementación real leerá de Firestore; la pantalla solo conoce
/// este contrato, lo que permite reemplazarlo en las pruebas.
abstract interface class CanchaRepository {
  Future<List<Cancha>> obtenerCanchas();
}
