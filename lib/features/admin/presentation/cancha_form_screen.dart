import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/widgets/mensaje_con_accion.dart';
import 'package:reservacancha/features/admin/presentation/cancha_form.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/presentation/admin_canchas_providers.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_providers.dart';

/// Pantalla para crear (`/admin/canchas/nueva`) o editar
/// (`/admin/canchas/:id/editar`) una cancha. Conecta [CanchaForm] con
/// `canchaFormControllerProvider`; el formulario no conoce los providers.
class CanchaFormScreen extends ConsumerWidget {
  const CanchaFormScreen({super.key, this.canchaId});

  /// `null` para una cancha nueva.
  final String? canchaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mantiene vivo el controlador (es autoDispose) mientras dure la pantalla.
    ref.watch(canchaFormControllerProvider);

    final id = canchaId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nueva cancha')),
        body: CanchaForm(
          alGuardar: (cancha) => _guardar(context, ref, cancha, nueva: true),
        ),
      );
    }

    final cancha = ref.watch(canchaProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Editar cancha')),
      body: cancha.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => MensajeConAccion(
          icono: Icons.cloud_off,
          mensaje: 'No pudimos cargar la cancha.',
          accion: 'Reintentar',
          alPresionar: () => ref.invalidate(canchaProvider(id)),
        ),
        data: (cancha) => cancha == null
            ? MensajeConAccion(
                icono: Icons.search_off,
                mensaje: 'Esta cancha ya no existe.',
                accion: 'Volver',
                alPresionar: () => context.pop(),
              )
            : CanchaForm(
                inicial: cancha,
                alGuardar: (editada) =>
                    _guardar(context, ref, editada, nueva: false),
              ),
      ),
    );
  }

  /// Guarda con el controlador. Si falló, vuelve a lanzar el error para que
  /// [CanchaForm] muestre el mensaje (por ejemplo, el de nombre repetido).
  Future<void> _guardar(
    BuildContext context,
    WidgetRef ref,
    Cancha cancha, {
    required bool nueva,
  }) async {
    await ref
        .read(canchaFormControllerProvider.notifier)
        .guardar(cancha, nueva: nueva);
    if (!context.mounted) return;

    final estado = ref.read(canchaFormControllerProvider);
    if (estado.hasError) throw estado.error!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nueva
              ? '«${cancha.nombre}» creada'
              : '«${cancha.nombre}» actualizada',
        ),
      ),
    );
    context.pop();
  }
}
