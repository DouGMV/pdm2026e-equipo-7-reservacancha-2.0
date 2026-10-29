import 'package:reservacancha/features/canchas/domain/cancha.dart';

extension CanchaConNombre on Cancha {
  Cancha conNombre({required String nombre, String? id, bool? activa}) =>
      Cancha(
        id: id ?? this.id,
        nombre: nombre,
        deporte: deporte,
        descripcion: descripcion,
        ubicacion: ubicacion,
        precioPorHora: precioPorHora,
        imagenUrl: imagenUrl,
        horaApertura: horaApertura,
        horaCierre: horaCierre,
        activa: activa ?? this.activa,
      );
}
