import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/core/utils/validators.dart';
import 'package:reservacancha/core/widgets/mensaje_con_accion.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/presentation/admin_canchas_providers.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_providers.dart';
import 'package:reservacancha/features/canchas/presentation/deportes.dart';

/// Formulario para agregar (`/admin/canchas/nueva`) o editar
/// (`/admin/canchas/:id/editar`) una cancha.
class CanchaFormScreen extends ConsumerWidget {
  const CanchaFormScreen({super.key, this.canchaId});

  /// `null` para una cancha nueva.
  final String? canchaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = canchaId;
    if (id == null) {
      return const _Formulario(cancha: null);
    }

    final cancha = ref.watch(canchaProvider(id));
    return cancha.when(
      skipLoadingOnRefresh: false,
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Editar cancha')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Editar cancha')),
        body: MensajeConAccion(
          icono: Icons.cloud_off,
          mensaje: 'No pudimos cargar la cancha.',
          accion: 'Reintentar',
          alPresionar: () => ref.invalidate(canchaProvider(id)),
        ),
      ),
      data: (cancha) => cancha == null
          ? Scaffold(
              appBar: AppBar(title: const Text('Editar cancha')),
              body: MensajeConAccion(
                icono: Icons.search_off,
                mensaje: 'Esta cancha ya no existe.',
                accion: 'Volver',
                alPresionar: () => context.pop(),
              ),
            )
          : _Formulario(cancha: cancha),
    );
  }
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({required this.cancha});

  final Cancha? cancha;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.cancha?.nombre);
  late final _ubicacion = TextEditingController(text: widget.cancha?.ubicacion);
  late final _descripcion = TextEditingController(
    text: widget.cancha?.descripcion,
  );
  late final _precio = TextEditingController(
    text: widget.cancha?.precioPorHora.toString(),
  );
  late final _imagenUrl = TextEditingController(text: widget.cancha?.imagenUrl);
  late String? _deporte = widget.cancha?.deporte;
  late int _apertura = widget.cancha?.horaApertura ?? 7;
  late int _cierre = widget.cancha?.horaCierre ?? 22;
  late bool _activa = widget.cancha?.activa ?? true;

  bool get _esNueva => widget.cancha == null;

  @override
  void dispose() {
    _nombre.dispose();
    _ubicacion.dispose();
    _descripcion.dispose();
    _precio.dispose();
    _imagenUrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final valido = _formKey.currentState?.validate() ?? false;
    if (!valido || ref.read(canchaFormControllerProvider).isLoading) return;

    final cancha = Cancha(
      id: widget.cancha?.id ?? '',
      nombre: _nombre.text.trim(),
      deporte: _deporte!,
      descripcion: _descripcion.text.trim(),
      ubicacion: _ubicacion.text.trim(),
      precioPorHora: num.parse(_precio.text.trim()),
      imagenUrl: _imagenUrl.text.trim(),
      horaApertura: _apertura,
      horaCierre: _cierre,
      activa: _activa,
    );
    await ref
        .read(canchaFormControllerProvider.notifier)
        .guardar(cancha, nueva: _esNueva);
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (ref.read(canchaFormControllerProvider).hasError) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No pudimos guardar la cancha. Intenta de nuevo.'),
        ),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _esNueva
              ? '«${cancha.nombre}» agregada'
              : '«${cancha.nombre}» actualizada',
        ),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final guardando = ref.watch(canchaFormControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(_esNueva ? 'Nueva cancha' : 'Editar cancha')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (valor) =>
                  validarRequerido(valor, mensaje: 'Introduce el nombre'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _deporte,
              decoration: const InputDecoration(labelText: 'Deporte'),
              items: [
                for (final MapEntry(:key, :value) in deportes.entries)
                  DropdownMenuItem(value: key, child: Text(value)),
              ],
              onChanged: (valor) => setState(() => _deporte = valor),
              validator: (valor) => valor == null ? 'Elige el deporte' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ubicacion,
              decoration: const InputDecoration(labelText: 'Ubicación'),
              validator: (valor) =>
                  validarRequerido(valor, mensaje: 'Introduce la ubicación'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _precio,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Precio por hora',
                prefixText: 'Q ',
              ),
              validator: validarPrecio,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _apertura,
                    decoration: const InputDecoration(labelText: 'Abre'),
                    items: [
                      for (var hora = 0; hora < 24; hora++)
                        DropdownMenuItem(
                          value: hora,
                          child: Text(formatearHora(hora)),
                        ),
                    ],
                    onChanged: (valor) => setState(() => _apertura = valor!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _cierre,
                    decoration: const InputDecoration(labelText: 'Cierra'),
                    items: [
                      for (var hora = 1; hora <= 24; hora++)
                        DropdownMenuItem(
                          value: hora,
                          child: Text(formatearHora(hora)),
                        ),
                    ],
                    onChanged: (valor) => setState(() => _cierre = valor!),
                    validator: (valor) => valor! <= _apertura
                        ? 'Debe ser después de la apertura'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcion,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imagenUrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Enlace de la foto (opcional)',
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Activa'),
              subtitle: const Text(
                'Las canchas inactivas no aparecen a los clientes',
              ),
              value: _activa,
              onChanged: (valor) => setState(() => _activa = valor),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: guardando ? null : _guardar,
            child: guardando
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_esNueva ? 'Agregar cancha' : 'Guardar cambios'),
          ),
        ),
      ),
    );
  }
}
