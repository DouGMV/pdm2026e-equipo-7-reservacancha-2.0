import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/features/reservas/domain/filtro_reservas.dart';
import 'package:reservacancha/features/reservas/presentation/mis_reservas_providers.dart';

void main() {
  test('el notifier publica un filtro nuevo sin mutar el anterior', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const inicial = FiltroReservas();
    expect(container.read(filtroReservasProvider), inicial);

    container
        .read(filtroReservasProvider.notifier)
        .cambiarEstado(EstadoFiltroReserva.canceladas);
    expect(
      container.read(filtroReservasProvider).estado,
      EstadoFiltroReserva.canceladas,
    );
    expect(inicial.estado, EstadoFiltroReserva.todas);

    container.read(filtroReservasProvider.notifier).cambiarMes('2026-10');
    final conMes = container.read(filtroReservasProvider);
    expect(conMes.estado, EstadoFiltroReserva.canceladas);
    expect(conMes.mes, '2026-10');

    container.read(filtroReservasProvider.notifier).limpiar();
    expect(container.read(filtroReservasProvider).sinFiltros, isTrue);
  });
}
