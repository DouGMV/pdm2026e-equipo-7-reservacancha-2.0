import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/router/app_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Inicio de sesión'),
              const SizedBox(height: 24),
              // La autenticación entra en el Sprint 1; por ahora el botón
              // entra a la app para poder navegar entre pantallas.
              FilledButton(
                onPressed: () => context.go(AppRoutes.inicio),
                child: const Text('Entrar'),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.registro),
                child: const Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
