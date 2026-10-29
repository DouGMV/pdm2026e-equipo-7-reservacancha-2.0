import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/data/migracion_provider.dart';
import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/core/theme/app_theme.dart';
import 'package:reservacancha/features/auth/presentation/auth_providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Solo el admin puede escribir en `canchas/`; si la migración falla, la
    // app sigue funcionando y se reintenta en el siguiente inicio de sesión.
    ref.listen(sesionProvider, (_, siguiente) {
      final usuario = siguiente.value;
      if (usuario == null || !usuario.esAdmin) return;
      unawaited(_migrarEnSegundoPlano(ref));
    });

    return MaterialApp.router(
      title: 'ReservaCancha',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }

  Future<void> _migrarEnSegundoPlano(WidgetRef ref) async {
    try {
      await ref.read(migrarEsquemaProvider)();
    } on Object {
      return;
    }
  }
}
