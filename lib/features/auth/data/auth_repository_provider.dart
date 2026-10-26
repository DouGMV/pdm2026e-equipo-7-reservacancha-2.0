import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/features/auth/data/auth_repository_firebase.dart';
import 'package:reservacancha/features/auth/domain/auth_repository.dart';

/// Repositorio de autenticación que usa la app: Firebase Auth.
/// En las pruebas se reemplaza por `AuthRepositoryFake` con un override.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) =>
      AuthRepositoryFirebase(FirebaseAuth.instance, FirebaseFirestore.instance),
);
