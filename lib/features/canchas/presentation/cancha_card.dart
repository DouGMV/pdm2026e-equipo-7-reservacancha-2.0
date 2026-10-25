import 'package:flutter/material.dart';

import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/presentation/deportes.dart';

/// Tarjeta del listado: imagen, nombre, deporte y precio por hora.
class CanchaCard extends StatelessWidget {
  const CanchaCard({super.key, required this.cancha});

  final Cancha cancha;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _ImagenCancha(cancha: cancha),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cancha.nombre, style: tema.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        nombreDeporte(cancha.deporte),
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${formatearMoneda(cancha.precioPorHora)}/h',
                  style: tema.textTheme.titleMedium?.copyWith(
                    color: tema.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Foto de la cancha. Mientras no haya foto (o si no carga), muestra el icono
/// del deporte sobre el color del tema.
class _ImagenCancha extends StatelessWidget {
  const _ImagenCancha({required this.cancha});

  final Cancha cancha;

  @override
  Widget build(BuildContext context) {
    final sinFoto = _SinFoto(deporte: cancha.deporte);
    if (cancha.imagenUrl.isEmpty) return sinFoto;
    return Image.network(
      cancha.imagenUrl,
      fit: BoxFit.cover,
      semanticLabel: cancha.nombre,
      errorBuilder: (context, error, stackTrace) => sinFoto,
    );
  }
}

class _SinFoto extends StatelessWidget {
  const _SinFoto({required this.deporte});

  final String deporte;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colores.primaryContainer,
      child: Icon(
        iconoDeporte(deporte),
        size: 64,
        color: colores.onPrimaryContainer,
        semanticLabel: nombreDeporte(deporte),
      ),
    );
  }
}
