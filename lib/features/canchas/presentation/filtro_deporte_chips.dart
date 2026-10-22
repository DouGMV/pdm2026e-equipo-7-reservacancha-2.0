import 'package:flutter/material.dart';

import 'package:reservacancha/features/canchas/presentation/deportes.dart';

/// Chips para filtrar por deporte: Todos y uno por deporte. Se reutilizan en
/// el listado del cliente (#18) y en la gestión de canchas.
class FiltroDeporteChips extends StatelessWidget {
  const FiltroDeporteChips({
    super.key,
    required this.seleccionado,
    required this.alSeleccionar,
  });

  /// Deporte activo; `null` significa todos.
  final String? seleccionado;
  final ValueChanged<String?> alSeleccionar;

  @override
  Widget build(BuildContext context) {
    final opciones = <String?, String>{null: 'Todos', ...deportes};
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (final MapEntry(key: deporte, value: nombre) in opciones.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(nombre),
                selected: seleccionado == deporte,
                onSelected: (_) => alSeleccionar(deporte),
              ),
            ),
        ],
      ),
    );
  }
}
