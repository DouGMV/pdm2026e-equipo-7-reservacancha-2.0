import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/reservas/data/reservas_repository_fake.dart';
import 'package:reservacancha/features/reservas/domain/reservas_repository.dart';

/// Repositorio de reservas que usa la app. Por ahora devuelve datos de
/// ejemplo; se reemplazará por la implementación con Firestore.
final reservasRepositoryProvider = Provider<ReservasRepository>(
  (ref) => const ReservasRepositoryFake(),
);
