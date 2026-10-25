import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/core/widgets/mensaje_con_accion.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/presentation/cancha_card.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_providers.dart';
import 'package:reservacancha/features/canchas/presentation/deportes.dart';
import 'package:reservacancha/features/canchas/presentation/filtro_deporte_chips.dart';

class CanchasScreen extends ConsumerWidget {
  const CanchasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroListadoProvider);
    final canchas = ref.watch(canchasProvider);
    final filtroNotifier = ref.read(filtroListadoProvider.notifier);
    void recargar() => ref.invalidate(canchasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Canchas')),
      body: Column(
        children: [
          FiltroDeporteChips(
            seleccionado: filtro.deporte,
            alSeleccionar: filtroNotifier.seleccionarDeporte,
          ),
          Expanded(
            // Sin skipLoadingOnRefresh, al reintentar seguiría viéndose el
            // error hasta que llegue la respuesta y el botón parecería no
            // hacer nada.
            child: canchas.when(
              skipLoadingOnRefresh: false,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => MensajeConAccion(
                icono: Icons.cloud_off,
                mensaje: 'No pudimos cargar las canchas.',
                accion: 'Reintentar',
                alPresionar: recargar,
              ),
              data: (canchas) {
                if (canchas.isNotEmpty) return _ListaCanchas(canchas: canchas);
                final deporte = filtro.deporte;
                return deporte == null
                    ? MensajeConAccion(
                        icono: Icons.sports_soccer,
                        mensaje: 'Aún no hay canchas disponibles.',
                        accion: 'Actualizar',
                        alPresionar: recargar,
                      )
                    : MensajeConAccion(
                        icono: Icons.filter_alt_off,
                        mensaje: 'No hay canchas de ${nombreDeporte(deporte)}.',
                        accion: 'Ver todas',
                        alPresionar: () =>
                            filtroNotifier.seleccionarDeporte(null),
                      );
              },
            ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: canchas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => CanchaCard(
        cancha: canchas[index],
        alTocar: () => context.push(AppRoutes.detalleDe(canchas[index].id)),
      ),
    );
  }
}
