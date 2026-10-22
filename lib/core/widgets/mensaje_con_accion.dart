import 'package:flutter/material.dart';

/// Mensaje centrado con un icono y un botón, para los estados de error y
/// vacío de los listados.
class MensajeConAccion extends StatelessWidget {
  const MensajeConAccion({
    super.key,
    required this.icono,
    required this.mensaje,
    required this.accion,
    required this.alPresionar,
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
