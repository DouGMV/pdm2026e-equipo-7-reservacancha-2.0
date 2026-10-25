import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/errors/reserva_no_disponible_exception.dart';
import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/core/router/navegacion_provider.dart';
import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/core/widgets/mensaje_con_accion.dart';
import 'package:reservacancha/features/canchas/presentation/deportes.dart';
import 'package:reservacancha/features/reservas/domain/solicitud_reserva.dart';
import 'package:reservacancha/features/reservas/presentation/reservar_providers.dart';

/// Resumen de la reserva antes de crearla (`/reserva/confirmar`).
class ConfirmarReservaScreen extends ConsumerWidget {
  const ConfirmarReservaScreen({super.key, required this.solicitud});

  /// `null` si se llegó a la ruta sin elegir cancha y hora.
  final SolicitudReserva? solicitud;

  Future<void> _confirmar(
    BuildContext context,
    WidgetRef ref,
    SolicitudReserva solicitud,
  ) async {
    final controlador = ref.read(reservarControllerProvider.notifier);
    await controlador.reservar(solicitud);
    if (!context.mounted) return;

    final estado = ref.read(reservarControllerProvider);
    if (!estado.hasError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('¡Reserva confirmada!')));
      ref.read(navegacionProvider.notifier).ir(Pestana.misReservas);
      context.go(AppRoutes.canchas);
      return;
    }

    if (estado.error is ReservaNoDisponibleException) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Horario no disponible'),
          content: const Text(
            'Otra persona acaba de reservar esta hora. Elige otra.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Elegir otra hora'),
            ),
          ],
        ),
      );
      if (context.mounted) context.pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No pudimos crear la reserva. Intenta de nuevo.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitud = this.solicitud;
    if (solicitud == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirmar reserva')),
        body: MensajeConAccion(
          icono: Icons.event_busy,
          mensaje: 'Primero elige una cancha y un horario.',
          accion: 'Ver canchas',
          alPresionar: () => context.go(AppRoutes.canchas),
        ),
      );
    }

    final enviando = ref.watch(reservarControllerProvider).isLoading;
    final tema = Theme.of(context);
    final dia = DateTime.parse(solicitud.fecha);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar reserva')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(iconoDeporte(solicitud.cancha.deporte)),
                  title: Text(solicitud.cancha.nombre),
                  subtitle: Text(nombreDeporte(solicitud.cancha.deporte)),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(formatearFechaLarga(dia)),
                  subtitle: Text(solicitud.fecha),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(formatearBloque(solicitud.hora)),
                  subtitle: const Text('1 hora'),
                ),
                if (solicitud.cancha.ubicacion.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(solicitud.cancha.ubicacion),
                  ),
                const Divider(height: 1),
                ListTile(
                  title: Text('Total', style: tema.textTheme.titleMedium),
                  trailing: Text(
                    formatearMoneda(solicitud.total),
                    style: tema.textTheme.titleLarge?.copyWith(
                      color: tema.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'El pago se realiza en la cancha. Puedes cancelar desde '
            '"Mis reservas" antes de la hora reservada.',
            style: tema.textTheme.bodySmall,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: enviando
                ? null
                : () => _confirmar(context, ref, solicitud),
            child: enviando
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirmar reserva'),
          ),
        ),
      ),
    );
  }
}
