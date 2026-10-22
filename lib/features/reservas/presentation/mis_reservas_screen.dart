import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/navigation/navegacion_provider.dart';
import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/core/widgets/mensaje_con_accion.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/presentation/mis_reservas_providers.dart';

class MisReservasScreen extends ConsumerWidget {
  const MisReservasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservas = ref.watch(misReservasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis reservas')),
      // Sin skipLoadingOnRefresh, al reintentar seguiría viéndose el error
      // hasta que llegue la respuesta y el botón parecería no hacer nada.
      body: reservas.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => MensajeConAccion(
          icono: Icons.cloud_off,
          mensaje: 'No pudimos cargar tus reservas.',
          accion: 'Reintentar',
          alPresionar: () => ref.invalidate(misReservasProvider),
        ),
        data: (reservas) => reservas.isEmpty
            ? MensajeConAccion(
                icono: Icons.event_available,
                mensaje: 'Aún no tienes reservas.',
                accion: 'Ver canchas',
                alPresionar: () =>
                    ref.read(navegacionProvider.notifier).irA(Pestana.canchas),
              )
            : _ListaReservas(reservas: reservas),
      ),
    );
  }
}

class _ListaReservas extends StatelessWidget {
  const _ListaReservas({required this.reservas});

  final List<Reserva> reservas;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return ListView.separated(
      itemCount: reservas.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final reserva = reservas[index];
        final confirmada = reserva.estado == EstadoReserva.confirmada;
        return ListTile(
          title: Text(reserva.canchaNombre),
          subtitle: Text('${reserva.fecha} · ${formatearHora(reserva.hora)}'),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatearMoneda(reserva.total)),
              Text(
                confirmada ? 'Confirmada' : 'Cancelada',
                style: TextStyle(
                  color: confirmada ? colores.primary : colores.error,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
