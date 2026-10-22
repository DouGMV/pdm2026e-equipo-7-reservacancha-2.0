import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/canchas_repository.dart';

/// Repositorio con datos de ejemplo mientras no exista la implementación con
/// Firestore. Simula la demora de la red con [Future.delayed].
class CanchasRepositoryFake implements CanchasRepository {
  const CanchasRepositoryFake({this.demora = const Duration(seconds: 1)});

  final Duration demora;

  @override
  Future<List<Cancha>> obtenerCanchas({String? deporte}) async {
    await Future<void>.delayed(demora);
    return [
      for (final cancha in _canchasDeEjemplo)
        if (deporte == null || cancha.deporte == deporte) cancha,
    ];
  }

  // TODO(#31): Nathaly implementa eliminar y restaurar sobre una lista en
  // memoria. Mientras tanto fallan, y la pantalla devuelve la fila.
  @override
  Future<void> eliminar(String id) async {
    await Future<void>.delayed(demora);
    throw UnimplementedError('eliminar pendiente (#31)');
  }

  @override
  Future<void> restaurar(Cancha cancha) async {
    await Future<void>.delayed(demora);
    throw UnimplementedError('restaurar pendiente (#31)');
  }
}

const List<Cancha> _canchasDeEjemplo = [
  Cancha(
    id: 'cancha-1',
    nombre: 'Cancha Sintética 1',
    deporte: 'futbol',
    descripcion: 'Fútbol 5 con grama sintética e iluminación nocturna.',
    ubicacion: 'Zona 3, Quetzaltenango',
    precioPorHora: 150,
    imagenUrl: '',
    horaApertura: 7,
    horaCierre: 22,
    activa: true,
  ),
  Cancha(
    id: 'cancha-2',
    nombre: 'Cancha Sintética 2',
    deporte: 'futbol',
    descripcion: 'Fútbol 7 con graderío techado.',
    ubicacion: 'Zona 3, Quetzaltenango',
    precioPorHora: 200,
    imagenUrl: '',
    horaApertura: 7,
    horaCierre: 22,
    activa: true,
  ),
  Cancha(
    id: 'cancha-3',
    nombre: 'Polideportivo Los Altos',
    deporte: 'basquetbol',
    descripcion: 'Cancha techada de duela.',
    ubicacion: 'Zona 1, Quetzaltenango',
    precioPorHora: 120,
    imagenUrl: '',
    horaApertura: 8,
    horaCierre: 21,
    activa: true,
  ),
  Cancha(
    id: 'cancha-4',
    nombre: 'Arena Voleibol Xela',
    deporte: 'voleibol',
    descripcion: 'Cancha de arena para voleibol de playa.',
    ubicacion: 'Zona 7, Quetzaltenango',
    precioPorHora: 100,
    imagenUrl: '',
    horaApertura: 8,
    horaCierre: 20,
    activa: true,
  ),
  Cancha(
    id: 'cancha-5',
    nombre: 'Pádel Club Mesoamericana',
    deporte: 'padel',
    descripcion: 'Cancha de pádel con paredes de vidrio.',
    ubicacion: 'Zona 9, Quetzaltenango',
    precioPorHora: 175,
    imagenUrl: '',
    horaApertura: 6,
    horaCierre: 22,
    activa: true,
  ),
];
