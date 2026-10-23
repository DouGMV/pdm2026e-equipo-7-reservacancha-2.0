import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/core/widgets/mensaje_con_accion.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_providers.dart';
import 'package:reservacancha/features/canchas/presentation/deportes.dart';

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
        error: (error, stackTrace) => MensajeConAccion(
          icono: Icons.cloud_off,
          mensaje: 'No pudimos cargar las canchas.',
          accion: 'Reintentar',
          alPresionar: recargar,
        ),
        data: (canchas) => canchas.isEmpty
            ? MensajeConAccion(
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
          subtitle: Text(nombreDeporte(cancha.deporte)),
          trailing: Text('${formatearMoneda(cancha.precioPorHora)}/h'),
        );
      },
    );
  }
}
