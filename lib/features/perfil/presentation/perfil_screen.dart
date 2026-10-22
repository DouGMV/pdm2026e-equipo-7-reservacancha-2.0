import 'package:flutter/material.dart';

import 'package:reservacancha/core/widgets/proximamente.dart';

/// El perfil se construye en el Sprint 3; mientras tanto, la pestaña muestra
/// "Próximamente".
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Proximamente(titulo: 'Perfil', icono: Icons.person_outline);
  }
}
