import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/auth/presentation/auth_providers.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';

/// Reservas del usuario. Se vuelve a consultar cuando cambia la sesión, para
/// no mostrar las reservas de otra persona. El reintento automático de
/// Riverpod 3 se desactiva para que el error llegue a la pantalla y el usuario
/// decida cuándo reintentar.
final misReservasProvider = FutureProvider<List<Reserva>>((ref) {
  ref.watch(sesionProvider.select((sesion) => sesion.value?.uid));
  return ref.watch(reservasRepositoryProvider).obtenerMisReservas();
}, retry: (_, _) => null);
