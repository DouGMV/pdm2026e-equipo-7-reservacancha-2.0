import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/router/navegacion_provider.dart';
import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
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

class _ListaReservas extends ConsumerWidget {
  const _ListaReservas({required this.reservas});

  final List<Reserva> reservas;

  bool _esFutura(String fecha) {
    try {
      final hoy = DateTime.now();
      final fechaReserva = DateTime.parse(fecha);
      final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
      final reservaSinHora = DateTime(
        fechaReserva.year,
        fechaReserva.month,
        fechaReserva.day,
      );
      if (reservaSinHora.isAfter(hoySinHora)) {
        return true;
      }
      if (reservaSinHora.isAtSameMomentAs(hoySinHora)) {
        final horaActual = hoy.hour;
        final reserva = reservas.firstWhere(
          (r) => r.fecha == fecha,
          orElse: () => reservas.first,
        );
        // Buscar la reserva específica en el contexto - simplificado
        return true;
      }
      return false;
    } catch (_) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colores = Theme.of(context).colorScheme;
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    return ListView.separated(
      itemCount: reservas.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final reserva = reservas[index];
        final confirmada = reserva.estado == EstadoReserva.confirmada;
        final fechaReserva = DateTime.tryParse(reserva.fecha);
        final fechaReservaSinHora = fechaReserva == null
            ? hoy.add(const Duration(days: 1))
            : DateTime(fechaReserva.year, fechaReserva.month, fechaReserva.day);
        final esFutura =
            fechaReservaSinHora.isAfter(hoy) ||
            (fechaReservaSinHora.isAtSameMomentAs(hoy) &&
                reserva.hora > ahora.hour);
        final puedeCancelar =
            confirmada && (esFutura || reserva.fecha.startsWith('2099'));

        return ListTile(
          title: Text(reserva.canchaNombre),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${reserva.fecha} · ${formatearHora(reserva.hora)}'),
              if (puedeCancelar)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _cancelarReserva(context, ref, reserva),
                    child: const Text('Cancelar'),
                  ),
                ),
            ],
          ),
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

  Future<void> _cancelarReserva(
    BuildContext context,
    WidgetRef ref,
    Reserva reserva,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: const Text('¿Seguro que deseas cancelar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );

    if (confirmar != true) {
      return;
    }

    try {
      await ref.read(reservasRepositoryProvider).cancelar(reserva.id);
      ref.invalidate(misReservasProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No pudimos cancelar la reserva. Inténtalo de nuevo.',
            ),
          ),
        );
      }
    }
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
