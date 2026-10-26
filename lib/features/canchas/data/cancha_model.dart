import 'package:reservacancha/features/canchas/domain/cancha.dart';

/// Conversión entre [Cancha] y el documento `canchas/{canchaId}` de Firestore.
abstract final class CanchaModel {
  static Cancha fromMap(String id, Map<String, dynamic> datos) {
    return Cancha(
      id: id,
      nombre: datos['nombre'] as String? ?? '',
      deporte: datos['deporte'] as String? ?? '',
      descripcion: datos['descripcion'] as String? ?? '',
      ubicacion: datos['ubicacion'] as String? ?? '',
      precioPorHora: datos['precioPorHora'] as num? ?? 0,
      imagenUrl: datos['imagenUrl'] as String? ?? '',
      horaApertura: (datos['horaApertura'] as num?)?.toInt() ?? 0,
      horaCierre: (datos['horaCierre'] as num?)?.toInt() ?? 0,
      activa: datos['activa'] as bool? ?? true,
    );
  }

  static Map<String, Object?> toMap(Cancha cancha) {
    return {
      'nombre': cancha.nombre,
      'deporte': cancha.deporte,
      'descripcion': cancha.descripcion,
      'ubicacion': cancha.ubicacion,
      'precioPorHora': cancha.precioPorHora,
      'imagenUrl': cancha.imagenUrl,
      'horaApertura': cancha.horaApertura,
      'horaCierre': cancha.horaCierre,
      'activa': cancha.activa,
    };
  }
}
