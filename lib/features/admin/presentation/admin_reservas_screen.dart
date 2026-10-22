import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/core/widgets/mensaje_con_accion.dart';
import 'package:reservacancha/features/admin/presentation/admin_reservas_providers.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';

class AdminReservasScreen extends ConsumerWidget {
  const AdminReservasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroReservasProvider);
    final reservas = ref.watch(reservasAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reservas')),
      body: Column(
        children: [
          _ChipsEstado(seleccionado: filtro.estado),
          Expanded(
            // skipLoadingOnRefresh: false -> al cambiar el filtro o reintentar
            // se ve el indicador de carga y no la lista anterior.
            child: reservas.when(
              skipLoadingOnRefresh: false,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => MensajeConAccion(
                icono: Icons.cloud_off,
                mensaje: 'No pudimos cargar las reservas.',
                accion: 'Reintentar',
                alPresionar: () => ref.invalidate(reservasAdminProvider),
              ),
              data: (lista) => lista.isEmpty
                  ? _Vacio(estado: filtro.estado)
                  : ListView.separated(
                      itemCount: lista.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) =>
                          _ReservaDeslizable(reserva: lista[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipsEstado extends ConsumerWidget {
  const _ChipsEstado({required this.seleccionado});

  final EstadoReserva? seleccionado;

  static const _opciones = <(EstadoReserva?, String)>[
    (null, 'Todas'),
    (EstadoReserva.confirmada, 'Confirmadas'),
    (EstadoReserva.cancelada, 'Canceladas'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(filtroReservasProvider.notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Wrap(
        spacing: 8,
        children: [
          for (final (estado, etiqueta) in _opciones)
            ChoiceChip(
              label: Text(etiqueta),
              selected: seleccionado == estado,
              onSelected: (_) => controller.estado(estado),
            ),
        ],
      ),
    );
  }
}

/// Estado vacío según el filtro: si hay un filtro activo, la acción lo quita.
class _Vacio extends ConsumerWidget {
  const _Vacio({required this.estado});

  final EstadoReserva? estado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (estado) {
      null => MensajeConAccion(
        icono: Icons.event_busy,
        mensaje: 'No hay reservas.',
        accion: 'Actualizar',
        alPresionar: () => ref.invalidate(reservasAdminProvider),
      ),
      final estado => MensajeConAccion(
        icono: Icons.filter_alt_off,
        mensaje: estado == EstadoReserva.confirmada
            ? 'No hay reservas confirmadas.'
            : 'No hay reservas canceladas.',
        accion: 'Ver todas',
        alPresionar: () =>
            ref.read(filtroReservasProvider.notifier).estado(null),
      ),
    };
  }
}

/// Deslizar a la izquierda elimina la reserva, con "Deshacer".
class _ReservaDeslizable extends ConsumerWidget {
  const _ReservaDeslizable({required this.reserva});

  final Reserva reserva;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colores = Theme.of(context).colorScheme;
    return Dismissible(
      // La key es el id: con el índice, al quitar una fila Flutter
      // confundiría las que quedan debajo.
      key: ValueKey(reserva.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: colores.errorContainer,
        child: Icon(Icons.delete_outline, color: colores.onErrorContainer),
      ),
      // Primero se elimina en el repositorio. Si falla, se devuelve false y
      // la fila regresa a su lugar.
      confirmDismiss: (_) async {
        final mensajes = ScaffoldMessenger.of(context);
        final controller = ref.read(reservasAdminProvider.notifier);
        try {
          await controller.eliminar(reserva);
          mensajes.showSnackBar(
            SnackBar(
              content: Text('Reserva de ${reserva.canchaNombre} eliminada'),
              action: SnackBarAction(
                label: 'Deshacer',
                onPressed: () => controller.restaurar(reserva),
              ),
            ),
          );
          return true;
        } on Exception {
          mensajes.showSnackBar(
            const SnackBar(content: Text('No se pudo eliminar la reserva.')),
          );
          return false;
        }
      },
      child: _FilaReserva(reserva: reserva),
    );
  }
}

class _FilaReserva extends StatelessWidget {
  const _FilaReserva({required this.reserva});

  final Reserva reserva;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final confirmada = reserva.estado == EstadoReserva.confirmada;
    return ListTile(
      title: Text(reserva.canchaNombre),
      subtitle: Text(
        '${reserva.fecha} · ${formatearHora(reserva.hora)} · '
        '${reserva.usuarioId}',
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
}
