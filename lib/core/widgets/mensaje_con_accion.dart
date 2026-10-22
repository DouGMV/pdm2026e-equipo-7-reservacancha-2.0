import 'package:flutter/material.dart';

/// Mensaje con una acción, para los estados de carga, error y vacío de los
/// listados (ver docs/ARQUITECTURA.md).
class MensajeConAccion extends StatelessWidget {
  const MensajeConAccion({
    required this.icono,
    required this.mensaje,
    required this.accion,
    required this.alPresionar,
    super.key,
  });

  final IconData icono;
  final String mensaje;
  final String accion;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 48, color: colores.primary),
            const SizedBox(height: 16),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: alPresionar, child: Text(accion)),
          ],
        ),
      ),
    );
  }
}
