import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/canchas/data/canchas_repository_fake.dart';
import 'package:reservacancha/features/canchas/domain/canchas_repository.dart';

/// Repositorio de canchas que usa la app. Por ahora devuelve datos de ejemplo;
/// se reemplazará por la implementación con Firestore.
final canchasRepositoryProvider = Provider<CanchasRepository>(
  (ref) => const CanchasRepositoryFake(),
);
