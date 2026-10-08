import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/router/app_router.dart';

/// Pantalla de inicio de sesión (issue #17).
/// UI con datos de ejemplo: la validación y el envío se conectarán
/// al provider de auth de Angel en el Sprint 1.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _enviando = false;

  Future<void> _iniciarSesion() async {
    final formValido = _formKey.currentState?.validate() ?? false;
    if (!formValido || _enviando) return;
    setState(() => _enviando = true);
    // TODO(sprint-1): reemplazar por el provider de autenticación de Angel.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    context.go(AppRoutes.canchas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.sports_soccer,
                  size: 72,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Introduce el correo electrónico';
                    }
                    if (!valor.contains('@')) {
                      return 'Introduce un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Introduce la contraseña';
                    }
                    if (valor.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _enviando ? null : _iniciarSesion,
                  child: _enviando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go(AppRoutes.registro),
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
