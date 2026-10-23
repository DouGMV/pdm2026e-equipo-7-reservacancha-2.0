import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/router/navegacion_provider.dart';
import 'package:reservacancha/core/utils/formatters.dart';
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
        error: (error, stackTrace) => _MensajeConAccion(
          icono: Icons.cloud_off,
          mensaje: 'No pudimos cargar tus reservas.',
          accion: 'Reintentar',
          alPresionar: () => ref.invalidate(misReservasProvider),
        ),
        data: (reservas) => reservas.isEmpty
            ? _MensajeConAccion(
                icono: Icons.event_available,
                mensaje: 'Aún no tienes reservas.',
                accion: 'Ver canchas',
                // Navega cambiando la pestaña activa, sin callbacks.
                alPresionar: () =>
                    ref.read(navegacionProvider.notifier).ir(Pestana.canchas),
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
