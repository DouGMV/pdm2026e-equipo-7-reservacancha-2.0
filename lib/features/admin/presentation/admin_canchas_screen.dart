import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/core/widgets/mensaje_con_accion.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/presentation/admin_canchas_providers.dart';
import 'package:reservacancha/features/canchas/presentation/deportes.dart';
import 'package:reservacancha/features/canchas/presentation/filtro_deporte_chips.dart';

class AdminCanchasScreen extends ConsumerWidget {
  const AdminCanchasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroCanchasProvider);
    final canchas = ref.watch(adminCanchasProvider);
    final filtroNotifier = ref.read(filtroCanchasProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de canchas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.nuevaCancha),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: Column(
        children: [
          FiltroDeporteChips(
            seleccionado: filtro.deporte,
            alSeleccionar: filtroNotifier.seleccionarDeporte,
          ),
          Expanded(
            child: canchas.when(
              skipLoadingOnRefresh: false,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => MensajeConAccion(
                icono: Icons.cloud_off,
                mensaje: 'No pudimos cargar las canchas.',
                accion: 'Reintentar',
                alPresionar: () => ref.invalidate(adminCanchasProvider),
              ),
              data: (canchas) {
                if (canchas.isNotEmpty) return _ListaCanchas(canchas: canchas);
                final deporte = filtro.deporte;
                return deporte == null
                    ? MensajeConAccion(
                        icono: Icons.sports_soccer,
                        mensaje:
                            'Aún no hay canchas registradas. Agrega una o '
                            'carga las de ejemplo para probar la app.',
                        accion: 'Cargar canchas de ejemplo',
                        alPresionar: () => _cargarEjemplos(
                          context,
                          ref.read(adminCanchasProvider.notifier),
                        ),
                      )
                    : MensajeConAccion(
                        icono: Icons.filter_alt_off,
                        mensaje: 'No hay canchas de ${nombreDeporte(deporte)}.',
                        accion: 'Ver todas',
                        alPresionar: () =>
                            filtroNotifier.seleccionarDeporte(null),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _cargarEjemplos(
  BuildContext context,
  AdminCanchasNotifier notifier,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await notifier.cargarEjemplos();
    messenger.showSnackBar(
      const SnackBar(content: Text('Canchas de ejemplo cargadas')),
    );
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('No pudimos cargar las canchas de ejemplo.'),
      ),
    );
  }
}

class _ListaCanchas extends ConsumerWidget {
  const _ListaCanchas({required this.canchas});

  final List<Cancha> canchas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(adminCanchasProvider.notifier);
    final colores = Theme.of(context).colorScheme;

    return ListView.separated(
      // Espacio para que el botón Agregar no tape la última fila.
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: canchas.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final cancha = canchas[index];
        final messenger = ScaffoldMessenger.of(context);
        return Dismissible(
          // El id y no el índice: al quitar una fila, las demás conservan su
          // key y Flutter no confunde una cancha con otra.
          key: ValueKey(cancha.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: colores.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Icon(Icons.delete, color: colores.onError),
          ),
          // Primero se borra en el repositorio; si falla, la fila vuelve.
          confirmDismiss: (_) async {
            try {
              await notifier.eliminar(cancha);
              return true;
            } catch (_) {
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('No pudimos eliminar «${cancha.nombre}».'),
                  ),
                );
              return false;
            }
          },
          onDismissed: (_) {
            notifier.quitarDeLaLista(cancha);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('«${cancha.nombre}» eliminada'),
                  persist: false,
                  action: SnackBarAction(
                    label: 'Deshacer',
                    onPressed: () => _restaurar(notifier, messenger, cancha),
                  ),
                ),
              );
          },
          child: ListTile(
            title: Text(cancha.nombre),
            subtitle: Text(
              cancha.activa
                  ? '${nombreDeporte(cancha.deporte)} · '
                        '${formatearMoneda(cancha.precioPorHora)}/h'
                  : '${nombreDeporte(cancha.deporte)} · Inactiva',
            ),
            trailing: Switch(
              value: cancha.activa,
              onChanged: (activa) =>
                  _cambiarActiva(notifier, messenger, cancha, activa),
            ),
            onTap: () => context.push(AppRoutes.editarDe(cancha.id)),
          ),
        );
      },
    );
  }

  Future<void> _cambiarActiva(
    AdminCanchasNotifier notifier,
    ScaffoldMessengerState messenger,
    Cancha cancha,
    bool activa,
  ) async {
    try {
      await notifier.cambiarActiva(cancha, activa: activa);
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text('No pudimos actualizar «${cancha.nombre}».')),
      );
    }
  }

  Future<void> _restaurar(
    AdminCanchasNotifier notifier,
    ScaffoldMessengerState messenger,
    Cancha cancha,
  ) async {
    try {
      await notifier.restaurar(cancha);
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text('No pudimos restaurar «${cancha.nombre}».')),
      );
    }
  }
}
