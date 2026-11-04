import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/errors/auth_exception.dart';
import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/core/utils/validators.dart';
import 'package:reservacancha/features/auth/presentation/auth_providers.dart';

/// Pantalla de inicio de sesión (UI: issue #17; lógica: issue #7).
/// No navega al terminar: al iniciar sesión, el `redirect` del router manda al
/// usuario a `/`.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final formValido = _formKey.currentState?.validate() ?? false;
    if (!formValido || ref.read(authControllerProvider).isLoading) return;

    await ref
        .read(authControllerProvider.notifier)
        .iniciarSesion(email: _correo.text, contrasena: _contrasena.text);
    if (!mounted) return;

    final estado = ref.read(authControllerProvider);
    if (estado.hasError) {
      final mensaje = switch (estado.error) {
        AuthException(:final mensaje) => mensaje,
        _ => 'No pudimos iniciar sesión. Intenta de nuevo.',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  Future<void> _recuperarContrasena() async {
    var correo = _correo.text.trim();
    final formKey = GlobalKey<FormState>();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: correo,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: validarCorreo,
            onChanged: (valor) => correo = valor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(correo.trim());
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    if (email == null || !mounted) return;

    await ref
        .read(authControllerProvider.notifier)
        .recuperarContrasena(email: email);
    if (!mounted) return;

    final estado = ref.read(authControllerProvider);
    final mensaje = estado.hasError
        ? switch (estado.error) {
            AuthException(:final mensaje) => mensaje,
            _ => 'No pudimos enviar el correo. Intenta de nuevo.',
          }
        : 'Si el correo está registrado, te enviamos un enlace.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final enviando = ref.watch(authControllerProvider).isLoading;

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
                Image.asset(
                  'assets/logo/logo.png',
                  width: 96,
                  height: 96,
                  semanticLabel: 'ReservaCancha',
                ),
                const SizedBox(height: 32),
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
                  controller: _contrasena,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: validarContrasena,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: enviando ? null : _recuperarContrasena,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: enviando ? null : _iniciarSesion,
                  child: enviando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.push(AppRoutes.registro),
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
