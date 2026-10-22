import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/navigation/navegacion_provider.dart';
import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/core/widgets/mensaje_con_accion.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/presentation/mis_reservas_providers.dart';

/// Pantalla de inicio: resumen de lo que falta por pagar y las últimas
/// reservas. Desde aquí se navega a otra pestaña cambiando el provider de
/// navegación, sin pasar funciones por los constructores.
class InicioScreen extends ConsumerWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservas = ref.watch(misReservasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
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
        data: (reservas) => _ResumenInicio(reservas: reservas),
      ),
    );
  }
}

class _ResumenInicio extends ConsumerWidget {
  const _ResumenInicio({required this.reservas});

  final List<Reserva> reservas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = _totalDelMesActual(reservas);
    final ultimas = reservas.take(3).toList();

    return ListView(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Te quedan este mes'),
            subtitle: Text(formatearMoneda(total)),
          ),
        ),
        ListTile(
          title: const Text('Últimos'),
          trailing: TextButton(
            onPressed: () =>
                ref.read(navegacionProvider.notifier).irA(Pestana.reservas),
            child: const Text('Ver todo'),
          ),
        ),
        if (ultimas.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Todavía no tienes reservas.'),
          )
        else
          for (final reserva in ultimas) _FichaReserva(reserva: reserva),
        const Divider(),
        ListTile(
          title: const Text('Ver canchas'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              ref.read(navegacionProvider.notifier).irA(Pestana.canchas),
        ),
      ],
    );
  }
}

class _FichaReserva extends StatelessWidget {
  const _FichaReserva({required this.reserva});

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

/// Suma de las reservas confirmadas del mes en curso.
num _totalDelMesActual(List<Reserva> reservas) {
  final mes = _mesActual();
  return reservas
      .where(
        (reserva) =>
            reserva.estado == EstadoReserva.confirmada &&
            reserva.fecha.startsWith(mes),
      )
      .fold<num>(0, (total, reserva) => total + reserva.total);
}

/// Mes en curso en formato `yyyy-MM`, el mismo formato de [Reserva.fecha].
String _mesActual() {
  final ahora = DateTime.now();
  final mes = ahora.month.toString().padLeft(2, '0');
  return '${ahora.year}-$mes';
}
