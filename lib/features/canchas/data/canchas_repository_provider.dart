import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/canchas/data/canchas_repository_fake.dart';
import 'package:reservacancha/features/canchas/domain/canchas_repository.dart';

/// Repositorio de canchas que usa la app. Por ahora trabaja sobre datos de
/// ejemplo en memoria; se reemplazará por la implementación con Firestore.
///
/// Un [Provider] crea la instancia una sola vez, así que lo eliminado sigue
/// eliminado mientras la app esté abierta.
final canchasRepositoryProvider = Provider<CanchasRepository>(
  (ref) => CanchasRepositoryFake(),
);
