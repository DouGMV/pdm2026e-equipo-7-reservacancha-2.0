import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/reservas/data/reservas_repository_fake.dart';
import 'package:reservacancha/features/reservas/domain/reservas_repository.dart';

/// Repositorio de reservas que usa la app. Por ahora es una lista en memoria
/// (una sola instancia: lo eliminado sigue eliminado mientras la app esté
/// abierta); se reemplazará por la implementación con Firestore.
final reservasRepositoryProvider = Provider<ReservasRepository>(
  (ref) => ReservasRepositoryFake(),
);
