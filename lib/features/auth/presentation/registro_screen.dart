import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/errors/auth_exception.dart';
import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/core/utils/validators.dart';
import 'package:reservacancha/features/auth/presentation/auth_providers.dart';

/// Pantalla de registro (UI: issue #17; lógica: issue #7).
/// No navega al terminar: al crear la cuenta queda la sesión iniciada y el
/// `redirect` del router manda al usuario a `/`.
class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _contrasena = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _telefono.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _registrarse() async {
    final formValido = _formKey.currentState?.validate() ?? false;
    if (!formValido || ref.read(authControllerProvider).isLoading) return;

    await ref
        .read(authControllerProvider.notifier)
        .registrar(
          nombre: _nombre.text,
          email: _correo.text,
          telefono: _telefono.text,
          contrasena: _contrasena.text,
        );
    if (!mounted) return;

    final estado = ref.read(authControllerProvider);
    if (estado.hasError) {
      final mensaje = switch (estado.error) {
        AuthException(:final mensaje) => mensaje,
        _ => 'No se pudo crear la cuenta. Intenta de nuevo.',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final enviando = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nombre,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (valor) =>
                      validarRequerido(valor, mensaje: 'Introduce tu nombre'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _correo,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: validarCorreo,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefono,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: validarTelefono,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contrasena,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: validarContrasena,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: enviando ? null : _registrarse,
                  child: enviando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crear cuenta'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
