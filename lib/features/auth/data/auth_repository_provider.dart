import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/auth/data/auth_repository_fake.dart';
import 'package:reservacancha/features/auth/domain/auth_repository.dart';

/// Repositorio de autenticación que usa la app. Por ahora es el fake en
/// memoria; al existir la implementación con Firebase solo cambia esta línea.
/// En las pruebas se reemplaza con `overrideWithValue`.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repositorio = AuthRepositoryFake();
  ref.onDispose(repositorio.dispose);
  return repositorio;
});
