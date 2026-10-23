import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO(sprint-0): inicializar Firebase cuando exista firebase_options.dart
  runApp(const ProviderScope(child: App()));
}
