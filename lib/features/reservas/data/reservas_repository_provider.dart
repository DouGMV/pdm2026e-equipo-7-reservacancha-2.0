import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/reservas/data/reservas_repository_fake.dart';
import 'package:reservacancha/features/reservas/domain/reservas_repository.dart';

/// Repositorio de reservas que usa la app. Por ahora guarda los datos en un
/// archivo local; se reemplazará por la implementación con Firestore.
final reservasRepositoryProvider = Provider<ReservasRepository>(
  (ref) => ReservasRepositoryFake(
    archivo: File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      'reservacancha_reservas.json',
    ),
  ),
);
