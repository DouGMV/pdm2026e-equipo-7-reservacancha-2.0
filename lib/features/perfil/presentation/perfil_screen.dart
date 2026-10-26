import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/widgets/mensaje_con_accion.dart';
import 'package:reservacancha/features/auth/domain/usuario.dart';
import 'package:reservacancha/features/auth/presentation/auth_providers.dart';

/// Datos del usuario con sesión y el botón para cerrarla (issue #44).
/// No navega al cerrar sesión: el `redirect` del router manda a `/login`.
class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(sesionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: sesion.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => MensajeConAccion(
          icono: Icons.cloud_off,
          mensaje: 'No pudimos cargar tu perfil.',
          accion: 'Reintentar',
          alPresionar: () => ref.invalidate(sesionProvider),
        ),
        // Sin sesión el router ya está llevando al usuario a `/login`.
        data: (usuario) => usuario == null
            ? const Center(child: CircularProgressIndicator())
            : _DatosUsuario(usuario: usuario),
      ),
    );
  }
}

class _DatosUsuario extends StatelessWidget {
  const _DatosUsuario({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Center(
          child: CircleAvatar(
            radius: 40,
            child: Text(
              _iniciales(usuario.nombre),
              style: tema.textTheme.headlineSmall,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          usuario.nombre,
          textAlign: TextAlign.center,
          style: tema.textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Correo electrónico'),
                subtitle: Text(usuario.email),
              ),
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Teléfono'),
                subtitle: Text(usuario.telefono),
              ),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Rol'),
                subtitle: Text(usuario.esAdmin ? 'Administrador' : 'Cliente'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _BotonCerrarSesion(),
      ],
    );
  }

  static String _iniciales(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    return partes
        .where((parte) => parte.isNotEmpty)
        .take(2)
        .map((parte) => parte[0].toUpperCase())
        .join();
  }
}

class _BotonCerrarSesion extends ConsumerWidget {
  const _BotonCerrarSesion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cerrando = ref.watch(authControllerProvider).isLoading;
    return OutlinedButton.icon(
      onPressed: cerrando ? null : () => _cerrarSesion(context, ref),
      icon: cerrando
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout),
      label: const Text('Cerrar sesión'),
    );
  }

  Future<void> _cerrarSesion(BuildContext context, WidgetRef ref) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Tendrás que volver a iniciar sesión para reservar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmado != true || !context.mounted) return;

    final mensajes = ScaffoldMessenger.of(context);
    await ref.read(authControllerProvider.notifier).cerrarSesion();
    // Si salió bien, el router ya quitó esta pantalla para ir a `/login`.
    if (!context.mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      mensajes.showSnackBar(
        const SnackBar(
          content: Text('No se pudo cerrar sesión. Intenta de nuevo.'),
        ),
      );
    }
  }
}
