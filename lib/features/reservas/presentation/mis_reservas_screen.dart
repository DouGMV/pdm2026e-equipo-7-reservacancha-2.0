import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/navigation/navegacion_provider.dart';
import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/core/widgets/mensaje_con_accion.dart';
import 'package:reservacancha/features/reservas/domain/filtro_reservas.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/presentation/mis_reservas_providers.dart';

class MisReservasScreen extends ConsumerWidget {
  const MisReservasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservas = ref.watch(misReservasFiltradasProvider);
    final filtro = ref.watch(filtroReservasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis reservas')),
      body: Column(
        children: [
          const _BarraFiltros(),
          Expanded(
            child: reservas.when(
              skipLoadingOnRefresh: false,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => MensajeConAccion(
                icono: Icons.cloud_off,
                mensaje: 'No pudimos cargar tus reservas.',
                accion: 'Reintentar',
                alPresionar: () => ref.invalidate(misReservasFiltradasProvider),
              ),
              data: (reservas) => reservas.isEmpty
                  ? _SinReservas(filtro: filtro)
                  : _ListaReservas(reservas: reservas),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chips para elegir el estado y el mes. Cada chip cambia el filtro en su
/// provider; el listado se actualiza porque lo escucha con `ref.watch`.
class _BarraFiltros extends ConsumerWidget {
  const _BarraFiltros();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroReservasProvider);
    final meses = ref.watch(mesesDisponiblesProvider);
    final notifier = ref.read(filtroReservasProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              for (final estado in EstadoFiltroReserva.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_etiquetaDeEstado(estado)),
                    selected: filtro.estado == estado,
                    onSelected: (_) => notifier.cambiarEstado(estado),
                  ),
                ),
            ],
          ),
        ),
        if (meses.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Todos los meses'),
                    selected: filtro.mes == null,
                    onSelected: (_) => notifier.cambiarMes(null),
                  ),
                ),
                for (final mes in meses)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(formatearMes(mes)),
                      selected: filtro.mes == mes,
                      onSelected: (_) => notifier.cambiarMes(mes),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

String _etiquetaDeEstado(EstadoFiltroReserva estado) => switch (estado) {
  EstadoFiltroReserva.todas => 'Todas',
  EstadoFiltroReserva.confirmadas => 'Confirmadas',
  EstadoFiltroReserva.canceladas => 'Canceladas',
};

class _SinReservas extends ConsumerWidget {
  const _SinReservas({required this.filtro});

  final FiltroReservas filtro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!filtro.sinFiltros) {
      return MensajeConAccion(
        icono: Icons.filter_alt_off,
        mensaje: 'No hay reservas con este filtro.',
        accion: 'Limpiar filtros',
        alPresionar: () => ref.read(filtroReservasProvider.notifier).limpiar(),
      );
    }
    return MensajeConAccion(
      icono: Icons.event_available,
      mensaje: 'Aún no tienes reservas.',
      accion: 'Ver canchas',
      alPresionar: () =>
          ref.read(navegacionProvider.notifier).irA(Pestana.canchas),
    );
  }
}

class _ListaReservas extends ConsumerWidget {
  const _ListaReservas({required this.reservas});

  final List<Reserva> reservas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      itemCount: reservas.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final reserva = reservas[index];
        return Dismissible(
          // La clave es el id, nunca el índice: al cambiar el filtro el índice
          // apuntaría a otra reserva y el borrado caería en la fila incorrecta.
          key: ValueKey(reserva.id),
          direction: DismissDirection.endToStart,
          background: const _FondoBorrar(),
          confirmDismiss: (_) => _confirmarBorrado(context, ref, reserva),
          onDismissed: (_) => _ofrecerDeshacer(context, ref, reserva),
          child: _FilaReserva(reserva: reserva),
        );
      },
    );
  }

  /// Borra primero en la base. Si falla devuelve `false` y la fila vuelve a
  /// su lugar con la reserva intacta.
  Future<bool> _confirmarBorrado(
    BuildContext context,
    WidgetRef ref,
    Reserva reserva,
  ) async {
    final eliminada = await ref
        .read(misReservasFiltradasProvider.notifier)
        .eliminar(reserva);
    if (!eliminada && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar la reserva. Intenta de nuevo.'),
        ),
      );
    }
    return eliminada;
  }

  void _ofrecerDeshacer(BuildContext context, WidgetRef ref, Reserva reserva) {
    ref.read(misReservasFiltradasProvider.notifier).quitar(reserva);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${reserva.canchaNombre} eliminada'),
          behavior: SnackBarBehavior.floating,
          // Por encima de la barra de pestañas.
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () async {
              final restaurada = await ref
                  .read(misReservasFiltradasProvider.notifier)
                  .restaurar(reserva);
              if (!restaurada && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo restaurar la reserva.'),
                  ),
                );
              }
            },
          ),
        ),
      );
  }
}

class _FondoBorrar extends StatelessWidget {
  const _FondoBorrar();

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      color: colores.errorContainer,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(Icons.delete_outline, color: colores.onErrorContainer),
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
  }
}
