import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/canchas_repository.dart';

/// Repositorio con datos de ejemplo mientras no exista la implementación con
/// Firestore. Trabaja sobre una lista en memoria y simula la demora de la red
/// con [Future.delayed].
///
/// Cada instancia parte de una copia de las canchas de ejemplo. Para que lo
/// eliminado siga eliminado mientras la app esté abierta, la app debe usar
/// siempre la misma instancia (ver `canchasRepositoryProvider`).
class CanchasRepositoryFake implements CanchasRepository {
  CanchasRepositoryFake({this.demora = const Duration(seconds: 1)});

  final Duration demora;

  final List<Cancha> _canchas = List<Cancha>.of(_canchasDeEjemplo);

  @override
  Future<List<Cancha>> obtenerCanchas({String? deporte}) async {
    await Future<void>.delayed(demora);
    return [
      for (final cancha in _canchas)
        if (deporte == null || cancha.deporte == deporte) cancha,
    ];
  }

  @override
  Future<void> eliminar(String id) async {
    await Future<void>.delayed(demora);
    final indice = _canchas.indexWhere((cancha) => cancha.id == id);
    if (indice == -1) {
      throw StateError('No existe una cancha con id $id');
    }
    _canchas.removeAt(indice);
  }

  @override
  Future<void> restaurar(Cancha cancha) async {
    await Future<void>.delayed(demora);
    if (_canchas.any((existente) => existente.id == cancha.id)) {
      return;
    }

    // Vuelve a su posición original: antes de la primera cancha que, en la
    // lista de ejemplo, venía después de ella. Si no es una cancha de ejemplo,
    // va al final.
    final orden = _ordenOriginal(cancha.id);
    var posicion = _canchas.length;
    if (orden != -1) {
      final siguiente = _canchas.indexWhere(
        (existente) => _ordenOriginal(existente.id) > orden,
      );
      if (siguiente != -1) {
        posicion = siguiente;
      }
    }
    _canchas.insert(posicion, cancha);
  }

  int _ordenOriginal(String id) =>
      _canchasDeEjemplo.indexWhere((cancha) => cancha.id == id);
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
