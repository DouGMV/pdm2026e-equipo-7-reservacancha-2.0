import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/core/widgets/mensaje_con_accion.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/presentation/cancha_card.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_providers.dart';
import 'package:reservacancha/features/canchas/presentation/deportes.dart';
import 'package:reservacancha/features/reservas/domain/horarios.dart';
import 'package:reservacancha/features/reservas/domain/solicitud_reserva.dart';
import 'package:reservacancha/features/reservas/presentation/reservar_providers.dart';

/// Detalle de una cancha (`/cancha/:id`): datos, fecha y hora a reservar.
class DetalleCanchaScreen extends ConsumerWidget {
  const DetalleCanchaScreen({super.key, required this.canchaId});

  final String canchaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cancha = ref.watch(canchaProvider(canchaId));

    return Scaffold(
      appBar: AppBar(title: Text(cancha.value?.nombre ?? 'Cancha')),
      body: cancha.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => MensajeConAccion(
          icono: Icons.cloud_off,
          mensaje: 'No pudimos cargar la cancha.',
          accion: 'Reintentar',
          alPresionar: () => ref.invalidate(canchaProvider(canchaId)),
        ),
        data: (cancha) => cancha == null || !cancha.activa
            ? MensajeConAccion(
                icono: Icons.search_off,
                mensaje: 'Esta cancha ya no está disponible.',
                accion: 'Ver canchas',
                alPresionar: () => context.go(AppRoutes.canchas),
              )
            : _Reservar(cancha: cancha),
      ),
    );
  }
}

class _Reservar extends ConsumerStatefulWidget {
  const _Reservar({required this.cancha});

  final Cancha cancha;

  @override
  ConsumerState<_Reservar> createState() => _ReservarState();
}

class _ReservarState extends ConsumerState<_Reservar> {
  late final List<DateTime> _dias = proximosDias(ref.read(relojProvider)());
  late DateTime _dia = _dias.first;
  int? _hora;

  @override
  Widget build(BuildContext context) {
    final cancha = widget.cancha;
    final tema = Theme.of(context);
    final fecha = formatearFecha(_dia);
    final ocupadas = ref.watch(
      horasOcupadasProvider((canchaId: cancha.id, fecha: fecha)),
    );
    final bloques = ocupadas.value == null
        ? const <BloqueHorario>[]
        : bloquesDelDia(
            cancha: cancha,
            dia: _dia,
            ocupadas: ocupadas.value!,
            ahora: ref.read(relojProvider)(),
          );
    // Si la hora elegida dejó de estar libre (por ejemplo, otra persona la
    // reservó), ya no cuenta como elegida.
    final hora = bloques.any((b) => b.hora == _hora && b.disponible)
        ? _hora
        : null;

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ImagenCancha(cancha: cancha),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombreDeporte(cancha.deporte),
                            style: tema.textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '${formatearMoneda(cancha.precioPorHora)}/h',
                          style: tema.textTheme.titleMedium?.copyWith(
                            color: tema.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    if (cancha.ubicacion.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 18,
                            color: tema.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(child: Text(cancha.ubicacion)),
                        ],
                      ),
                    ],
                    if (cancha.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(cancha.descripcion),
                    ],
                    const SizedBox(height: 24),
                    Text('Fecha', style: tema.textTheme.titleSmall),
                  ],
                ),
              ),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _dias.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final dia = _dias[index];
                    return ChoiceChip(
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(index == 0 ? 'Hoy' : abreviarDia(dia)),
                          Text('${dia.day}', style: tema.textTheme.titleMedium),
                        ],
                      ),
                      selected: dia == _dia,
                      showCheckmark: false,
                      onSelected: (_) => setState(() {
                        _dia = dia;
                        _hora = null;
                      }),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Hora · ${formatearFechaLarga(_dia)}',
                  style: tema.textTheme.titleSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ocupadas.when(
                  skipLoadingOnRefresh: false,
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => MensajeConAccion(
                    icono: Icons.cloud_off,
                    mensaje: 'No pudimos cargar los horarios.',
                    accion: 'Reintentar',
                    alPresionar: () => ref.invalidate(horasOcupadasProvider),
                  ),
                  data: (_) => bloques.any((b) => b.disponible)
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final bloque in bloques)
                              ChoiceChip(
                                label: Text(formatearHora(bloque.hora)),
                                selected: bloque.hora == hora,
                                onSelected: bloque.disponible
                                    ? (_) => setState(() => _hora = bloque.hora)
                                    : null,
                              ),
                          ],
                        )
                      : const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No quedan horarios libres este día. '
                              'Prueba con otra fecha.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: hora == null
                    ? null
                    : () => context.push(
                        AppRoutes.confirmarReserva,
                        extra: SolicitudReserva(
                          cancha: cancha,
                          fecha: fecha,
                          hora: hora,
                        ),
                      ),
                child: Text(
                  hora == null
                      ? 'Elige una hora'
                      : 'Continuar · ${formatearBloque(hora)}',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
