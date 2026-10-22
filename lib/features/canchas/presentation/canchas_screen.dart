import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_providers.dart';

class CanchasScreen extends ConsumerWidget {
  const CanchasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canchas = ref.watch(canchasProvider);
    void recargar() => ref.invalidate(canchasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Canchas')),
      // Sin skipLoadingOnRefresh, al reintentar seguiría viéndose el error
      // hasta que llegue la respuesta y el botón parecería no hacer nada.
      body: canchas.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _MensajeConAccion(
          icono: Icons.cloud_off,
          mensaje: 'No pudimos cargar las canchas.',
          accion: 'Reintentar',
          alPresionar: recargar,
        ),
        data: (canchas) => canchas.isEmpty
            ? _MensajeConAccion(
                icono: Icons.sports_soccer,
                mensaje: 'Aún no hay canchas disponibles.',
                accion: 'Actualizar',
                alPresionar: recargar,
              )
            : _ListaCanchas(canchas: canchas),
      ),
    );
  }
}

class _ListaCanchas extends StatelessWidget {
  const _ListaCanchas({required this.canchas});

  final List<Cancha> canchas;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: canchas.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final cancha = canchas[index];
        return ListTile(
          title: Text(cancha.nombre),
          subtitle: Text(_nombreDeporte(cancha.deporte)),
          trailing: Text('${formatearMoneda(cancha.precioPorHora)}/h'),
        );
      },
    );
  }
}

class _MensajeConAccion extends StatelessWidget {
  const _MensajeConAccion({
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

String _nombreDeporte(String deporte) => switch (deporte) {
  'futbol' => 'Fútbol',
  'basquetbol' => 'Básquetbol',
  'voleibol' => 'Voleibol',
  'padel' => 'Pádel',
  _ => deporte,
};
