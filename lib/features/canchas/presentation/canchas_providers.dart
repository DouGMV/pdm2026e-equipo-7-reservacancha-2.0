import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';

/// Listado de canchas. El reintento automático de Riverpod 3 se desactiva para
/// que el error llegue a la pantalla y el usuario decida cuándo reintentar.
final canchasProvider = FutureProvider<List<Cancha>>(
  (ref) => ref.watch(canchasRepositoryProvider).obtenerCanchas(),
  retry: (_, _) => null,
);
