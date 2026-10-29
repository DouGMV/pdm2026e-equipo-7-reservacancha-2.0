import 'package:flutter/material.dart';

import 'package:reservacancha/core/errors/cancha_duplicada_exception.dart';
import 'package:reservacancha/core/utils/formatters.dart';
import 'package:reservacancha/core/utils/validators.dart';
import 'package:reservacancha/features/canchas/domain/cancha.dart';
import 'package:reservacancha/features/canchas/presentation/deportes.dart';

/// El mismo formulario crea y edita una cancha (laboratorio S16).
///
/// Con [inicial] en `null` crea una nueva; con una cancha, muestra sus datos y
/// guarda los cambios **con el mismo id**. No conoce providers ni Firestore:
/// quien lo usa decide qué hacer en [alGuardar].
class CanchaForm extends StatefulWidget {
  const CanchaForm({super.key, this.inicial, required this.alGuardar});

  final Cancha? inicial;

  /// Guarda la cancha. Si lanza [CanchaDuplicadaException], el mensaje se
  /// muestra bajo el campo Nombre; cualquier otro error, en un aviso.
  final Future<void> Function(Cancha cancha) alGuardar;

  @override
  State<CanchaForm> createState() => _CanchaFormState();
}

class _CanchaFormState extends State<CanchaForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.inicial?.nombre);
  late final _ubicacion = TextEditingController(
    text: widget.inicial?.ubicacion,
  );
  late final _descripcion = TextEditingController(
    text: widget.inicial?.descripcion,
  );
  late final _precio = TextEditingController(
    text: widget.inicial?.precioPorHora.toString(),
  );
  late final _imagenUrl = TextEditingController(
    text: widget.inicial?.imagenUrl,
  );
  late String? _deporte = widget.inicial?.deporte;
  late int _apertura = widget.inicial?.horaApertura ?? 7;
  late int _cierre = widget.inicial?.horaCierre ?? 22;
  late bool _activa = widget.inicial?.activa ?? true;

  bool _guardando = false;

  /// Mensaje de nombre repetido; se borra al escribir otro nombre.
  String? _errorNombre;

  bool get _esNueva => widget.inicial == null;

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
    setState(() => _errorNombre = null);
    final valido = _formKey.currentState?.validate() ?? false;
    if (!valido || _guardando) return;

    final cancha = Cancha(
      // Editar conserva el id: se actualiza el mismo documento.
      id: widget.inicial?.id ?? '',
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

    setState(() => _guardando = true);
    try {
      await widget.alGuardar(cancha);
    } on CanchaDuplicadaException catch (error) {
      if (mounted) setState(() => _errorNombre = error.mensaje);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pudimos guardar la cancha. Intenta de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nombre,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    errorText: _errorNombre,
                  ),
                  onChanged: (_) {
                    if (_errorNombre != null) {
                      setState(() => _errorNombre = null);
                    }
                  },
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
                  validator: (valor) =>
                      valor == null ? 'Elige el deporte' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ubicacion,
                  decoration: const InputDecoration(labelText: 'Ubicación'),
                  validator: (valor) => validarRequerido(
                    valor,
                    mensaje: 'Introduce la ubicación',
                  ),
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
                        onChanged: (valor) =>
                            setState(() => _apertura = valor!),
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
                    'Desactívala para archivarla: deja de aparecer a los '
                    'clientes sin borrarse',
                  ),
                  value: _activa,
                  onChanged: (valor) => setState(() => _activa = valor),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_esNueva ? 'Crear' : 'Guardar cambios'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
