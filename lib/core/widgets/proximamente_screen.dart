import 'package:flutter/material.dart';

/// Pantalla que se muestra cuando una sección todavía no existe. Evita dejar
/// botones sin hacer nada: siempre avisan al usuario qué va a llegar.
class ProximamenteScreen extends StatelessWidget {
  const ProximamenteScreen({required this.titulo, super.key});

  /// Nombre de la sección que todavía no está disponible.
  final String titulo;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Próximamente')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_empty, size: 48, color: colores.primary),
              const SizedBox(height: 16),
              Text(
                '$titulo estará disponible pronto.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Mientras tanto puedes seguir usando el resto de la app.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
