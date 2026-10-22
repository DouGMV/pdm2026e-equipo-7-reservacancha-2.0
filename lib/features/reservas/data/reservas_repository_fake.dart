import 'dart:convert';
import 'dart:io';

import 'package:reservacancha/features/reservas/domain/filtro_reservas.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/domain/reservas_repository.dart';

/// Repositorio local mientras no exista la implementación con Firestore.
///
/// Guarda las reservas en un archivo JSON para que el borrado y el «Deshacer»
/// sobrevivan a cerrar la app. Si [archivo] es `null` solo usa memoria.
/// Simula la demora de la red con [Future.delayed].
class ReservasRepositoryFake implements ReservasRepository {
  ReservasRepositoryFake({
    this.demora = const Duration(seconds: 1),
    this.demoraEscritura = const Duration(milliseconds: 400),
    this.archivo,
  });

  final Duration demora;
  final Duration demoraEscritura;

  /// Archivo donde se guardan los cambios, por ejemplo dentro de
  /// `Directory.systemTemp`. Si es `null`, los cambios viven solo en memoria.
  final File? archivo;

  List<Reserva>? _reservas;

  @override
  Future<List<Reserva>> obtenerMisReservas({
    FiltroReservas filtro = const FiltroReservas(),
  }) async {
    await Future<void>.delayed(demora);
    final reservas = await _cargar();
    return [
      for (final reserva in reservas)
        if (filtro.incluye(reserva)) reserva,
    ]..sort(reservaMasRecientePrimero);
  }

  @override
  Future<void> eliminarReserva(String id) async {
    await Future<void>.delayed(demoraEscritura);
    final reservas = await _cargar();
    final antes = reservas.length;
    reservas.removeWhere((reserva) => reserva.id == id);
    if (reservas.length != antes) {
      await _guardar(reservas);
    }
  }

  @override
  Future<void> restaurarReserva(Reserva reserva) async {
    await Future<void>.delayed(demoraEscritura);
    final reservas = await _cargar();
    if (reservas.any((actual) => actual.id == reserva.id)) {
      return;
    }
    reservas.add(reserva);
    await _guardar(reservas);
  }

  Future<List<Reserva>> _cargar() async {
    final enMemoria = _reservas;
    if (enMemoria != null) {
      return enMemoria;
    }

    final desdeArchivo = await _leerArchivo();
    return _reservas = desdeArchivo ?? List.of(_reservasDeEjemplo);
  }

  Future<List<Reserva>?> _leerArchivo() async {
    final archivo = this.archivo;
    if (archivo == null || !await archivo.exists()) {
      return null;
    }
    try {
      final lista = jsonDecode(await archivo.readAsString()) as List<dynamic>;
      return [
        for (final item in lista)
          _reservaDesdeJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      // Archivo dañado o sin permisos: se empieza con los datos de ejemplo.
      return null;
    }
  }

  Future<void> _guardar(List<Reserva> reservas) async {
    final archivo = this.archivo;
    if (archivo == null) {
      return;
    }
    try {
      final texto = jsonEncode([
        for (final reserva in reservas) _reservaAJson(reserva),
      ]);
      await archivo.writeAsString(texto);
    } catch (_) {
      // Sin permiso de escritura la app sigue funcionando en memoria.
    }
  }
}

Map<String, Object?> _reservaAJson(Reserva reserva) => {
  'id': reserva.id,
  'canchaId': reserva.canchaId,
  'canchaNombre': reserva.canchaNombre,
  'usuarioId': reserva.usuarioId,
  'fecha': reserva.fecha,
  'hora': reserva.hora,
  'estado': reserva.estado.name,
  'total': reserva.total,
};

Reserva _reservaDesdeJson(Map<String, dynamic> json) => Reserva(
  id: json['id'] as String,
  canchaId: json['canchaId'] as String,
  canchaNombre: json['canchaNombre'] as String,
  usuarioId: json['usuarioId'] as String,
  fecha: json['fecha'] as String,
  hora: json['hora'] as int,
  estado: EstadoReserva.values.byName(json['estado'] as String),
  total: json['total'] as num,
);

const List<Reserva> _reservasDeEjemplo = [
  Reserva(
    id: 'cancha-1_20261020_18',
    canchaId: 'cancha-1',
    canchaNombre: 'Cancha Sintética 1',
    usuarioId: 'usuario-demo',
    fecha: '2026-10-20',
    hora: 18,
    estado: EstadoReserva.confirmada,
    total: 150,
  ),
  Reserva(
    id: 'cancha-5_20261022_7',
    canchaId: 'cancha-5',
    canchaNombre: 'Pádel Club Mesoamericana',
    usuarioId: 'usuario-demo',
    fecha: '2026-10-22',
    hora: 7,
    estado: EstadoReserva.confirmada,
    total: 175,
  ),
  Reserva(
    id: 'cancha-3_20261012_19',
    canchaId: 'cancha-3',
    canchaNombre: 'Polideportivo Los Altos',
    usuarioId: 'usuario-demo',
    fecha: '2026-10-12',
    hora: 19,
    estado: EstadoReserva.cancelada,
    total: 120,
  ),
];
