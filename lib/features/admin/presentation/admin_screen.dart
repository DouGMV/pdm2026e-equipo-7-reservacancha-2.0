import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/router/app_router.dart';

/// Pestaña Admin: accesos a las pantallas de administración. La visibilidad
/// según el rol (solo `admin`) se agrega con la redirección por rol.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administración')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.stadium_outlined),
            title: const Text('Gestión de canchas'),
            subtitle: const Text('Filtrar y eliminar canchas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.adminCanchas),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.event_note_outlined),
            title: const Text('Reservas'),
            subtitle: const Text('Filtrar y eliminar reservas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.adminReservas),
          ),
        ],
      ),
    );
  }
}
