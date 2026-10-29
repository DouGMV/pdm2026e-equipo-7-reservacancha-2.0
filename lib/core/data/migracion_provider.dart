import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/data/migrador_esquema.dart';

/// Ejecuta la migración del esquema con Firestore. En las pruebas se reemplaza
/// por una función falsa.
final migrarEsquemaProvider = Provider<Future<void> Function()>(
  (ref) => MigradorEsquema(FirebaseFirestore.instance).migrar,
);
