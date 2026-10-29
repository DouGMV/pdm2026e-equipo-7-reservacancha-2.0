import 'package:flutter_riverpod/misc.dart';
import 'package:reservacancha/features/auth/data/auth_repository_fake.dart';
import 'package:reservacancha/features/auth/data/auth_repository_provider.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';
import 'package:reservacancha/features/auth/presentation/auth_providers.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_fake.dart';
import 'package:reservacancha/features/canchas/data/canchas_repository_provider.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_fake.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';

/// Reemplaza los repositorios de Firebase por los de memoria, para probar la
/// app completa sin conexión ni Firebase inicializado.
List<Override> repositoriosEnMemoria({Usuario? sesionInicial}) => [
  authRepositoryProvider.overrideWith((ref) {
    final repositorio = AuthRepositoryFake(sesionInicial: sesionInicial);
    ref.onDispose(repositorio.dispose);
    return repositorio;
  }),
  canchasRepositoryProvider.overrideWith((ref) => CanchasRepositoryFake()),
  reservasRepositoryProvider.overrideWith(
    (ref) => ReservasRepositoryFake(
      usuarioActual: () => ref.read(sesionProvider).value?.uid ?? usuarioDemo,
    ),
  ),
];
