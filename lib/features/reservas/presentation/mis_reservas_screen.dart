import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/router/navegacion_provider.dart';
import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/core/widgets/mensaje_con_accion.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/presentation/mis_reservas_providers.dart';
import 'package:reservacancha/features/reservas/presentation/reservar_providers.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ahora = ref.watch(relojProvider)();
    final proximas = [
      for (final reserva in reservas)
        if (reserva.sePuedeCancelar(ahora)) reserva,
    ]..sort((a, b) => _inicio(a)!.compareTo(_inicio(b)!));
    final historial =
        [
          for (final reserva in reservas)
            if (!reserva.sePuedeCancelar(ahora)) reserva,
        ]..sort((a, b) {
          final inicioA = _inicio(a);
          final inicioB = _inicio(b);
          if (inicioA == null) return 1;
          if (inicioB == null) return -1;
          return inicioB.compareTo(inicioA);
        });

    return ListView(
      children: [
        if (proximas.isNotEmpty) ...[
          const _Encabezado('Próximas'),
          for (final reserva in proximas) _FilaReserva(reserva: reserva),
        ],
        if (historial.isNotEmpty) ...[
          const _Encabezado('Historial'),
          for (final reserva in historial) _FilaReserva(reserva: reserva),
        ],
      ],
    );
  }

  static DateTime? _inicio(Reserva reserva) {
    final fecha = DateTime.tryParse(reserva.fecha);
    if (fecha == null) return null;
    return DateTime(fecha.year, fecha.month, fecha.day, reserva.hora);
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        texto,
        style: tema.textTheme.titleSmall?.copyWith(
          color: tema.colorScheme.primary,
        ),
      ),
    );
  }
}

class _FilaReserva extends ConsumerWidget {
  const _FilaReserva({required this.reserva});

  final Reserva reserva;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colores = Theme.of(context).colorScheme;
    final confirmada = reserva.estado == EstadoReserva.confirmada;
    final puedeCancelar = reserva.sePuedeCancelar(ref.watch(relojProvider)());
    final fecha = DateTime.tryParse(reserva.fecha);

    return ListTile(
      title: Text(reserva.canchaNombre),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${fecha == null ? reserva.fecha : formatearFechaLarga(fecha)} · '
            '${formatearBloque(reserva.hora)}',
          ),
          if (puedeCancelar)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
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
