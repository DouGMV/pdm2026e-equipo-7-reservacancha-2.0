import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/router/navegacion_provider.dart';
import 'package:reservacancha/features/admin/presentation/admin_screen.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_screen.dart';
import 'package:reservacancha/features/perfil/presentation/perfil_screen.dart';
import 'package:reservacancha/features/reservas/presentation/mis_reservas_screen.dart';

/// Pantalla principal (`/`): la barra inferior y una pantalla por pestaña.
class InicioShell extends ConsumerWidget {
  const InicioShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actual = ref.watch(navegacionProvider);

    return Scaffold(
      // IndexedStack construye todas las pantallas y muestra una: cada pestaña
      // conserva su scroll y sus filtros al cambiar de pestaña.
      body: IndexedStack(
        index: actual.index,
        children: const [
          CanchasScreen(),
          MisReservasScreen(),
          AdminScreen(),
          PerfilScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: actual.index,
        onDestinationSelected: (indice) =>
            ref.read(navegacionProvider.notifier).ir(Pestana.values[indice]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer),
            label: 'Canchas',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Mis reservas',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
