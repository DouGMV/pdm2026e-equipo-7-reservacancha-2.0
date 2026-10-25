import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/canchas/data/canchas_repository_firestore.dart';
import 'package:reservacancha/features/canchas/domain/canchas_repository.dart';

/// Repositorio de canchas que usa la app: Cloud Firestore.
/// En las pruebas se reemplaza por `CanchasRepositoryFake` con un override.
final canchasRepositoryProvider = Provider<CanchasRepository>(
  (ref) => CanchasRepositoryFirestore(FirebaseFirestore.instance),
);
