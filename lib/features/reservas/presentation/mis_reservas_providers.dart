import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';

/// Reservas del usuario. El reintento automático de Riverpod 3 se desactiva
/// para que el error llegue a la pantalla y el usuario decida cuándo reintentar.
final misReservasProvider = FutureProvider<List<Reserva>>(
  (ref) => ref.watch(reservasRepositoryProvider).obtenerMisReservas(),
  retry: (_, _) => null,
);
