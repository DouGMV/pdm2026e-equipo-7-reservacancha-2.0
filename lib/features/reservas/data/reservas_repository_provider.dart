import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/reservas/data/reservas_repository_firestore.dart';
import 'package:reservacancha/features/reservas/domain/reservas_repository.dart';

/// Repositorio de reservas que usa la app: Cloud Firestore.
/// En las pruebas se reemplaza por `ReservasRepositoryFake` con un override.
final reservasRepositoryProvider = Provider<ReservasRepository>(
  (ref) => ReservasRepositoryFirestore(
    FirebaseFirestore.instance,
    usuarioActual: () => FirebaseAuth.instance.currentUser?.uid,
  ),
);
