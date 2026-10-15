import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/domain/cancha_repository.dart';

/// Implementación provisional con datos fijos.
///
/// Simula la latencia de la red con [Future.delayed] para que la pantalla
/// muestre el estado de carga. Se reemplazará por la lectura de Firestore
/// cuando la capa data esté lista (issue #5).
class CanchaRepositoryImpl implements CanchaRepository {
  CanchaRepositoryImpl({this.latencia = const Duration(milliseconds: 800)});

  /// Retardo simulado; en las pruebas se puede reducir a cero.
  final Duration latencia;

  static const _canchasEjemplo = <Cancha>[
    Cancha(
      id: 'cancha-1',
      nombre: 'Cancha Sintética 1',
      deporte: 'futbol',
      precioPorHora: 150,
      descripcion: 'Cancha de fútbol 7 con iluminación nocturna.',
      ubicacion: 'Zona 5, Quetzaltenango',
    ),
    Cancha(
      id: 'cancha-2',
      nombre: 'Cancha Techada 2',
      deporte: 'basquetbol',
      precioPorHora: 120,
      descripcion: 'Cancha de básquetbol techada, piso de concreto pulido.',
      ubicacion: 'Zona 3, Quetzaltenango',
    ),
    Cancha(
      id: 'cancha-3',
      nombre: 'Cancha Multiusos 3',
      deporte: 'voleibol',
      precioPorHora: 100,
      descripcion: 'Cancha para voleibol y microfútbol.',
      ubicacion: 'Zona 1, Quetzaltenango',
    ),
  ];

  @override
  Future<List<Cancha>> obtenerCanchas() async {
    await Future<void>.delayed(latencia);
    return _canchasEjemplo;
  }
}
