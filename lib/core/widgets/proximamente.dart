import 'package:flutter/material.dart';

/// Pantalla para las secciones que todavía no existen: así ningún botón de
/// la barra queda sin hacer nada.
class Proximamente extends StatelessWidget {
  const Proximamente({super.key, required this.titulo, required this.icono});

  final String titulo;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 48, color: colores.primary),
              const SizedBox(height: 16),
              const Text('Próximamente', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              const Text(
                'Esta sección estará disponible en un próximo sprint.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
