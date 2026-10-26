import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reservacancha/core/router/navegacion_provider.dart';
import 'package:reservacancha/features/admin/presentation/admin_screen.dart';
import 'package:reservacancha/features/auth/presentation/auth_providers.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_screen.dart';
import 'package:reservacancha/features/perfil/presentation/perfil_screen.dart';
import 'package:reservacancha/features/reservas/presentation/mis_reservas_screen.dart';

/// Pantalla principal (`/`): la barra inferior y una pantalla por pestaña.
///
/// La pestaña Admin solo aparece si el usuario con sesión es `admin`; las rutas
/// `/admin/...` además están protegidas por el `redirect` del router.
class InicioShell extends ConsumerWidget {
  const InicioShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actual = ref.watch(navegacionProvider);
    final sesion = ref.watch(sesionProvider);
    final esAdmin =
        sesion.hasValue &&
        !sesion.hasError &&
        (sesion.requireValue?.esAdmin ?? false);

    final pestanas = [
      for (final pestana in Pestana.values)
        if (pestana != Pestana.admin || esAdmin) pestana,
    ];
    // Si la pestaña activa no está disponible para este rol (por ejemplo,
    // quedó en Admin de una sesión anterior), se muestra Canchas.
    final indice = pestanas.contains(actual) ? pestanas.indexOf(actual) : 0;

    return Scaffold(
      // IndexedStack construye todas las pantallas y muestra una: cada pestaña
      // conserva su scroll y sus filtros al cambiar de pestaña.
      body: IndexedStack(
        index: indice,
        children: [for (final pestana in pestanas) _pantalla(pestana)],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: indice,
        onDestinationSelected: (i) =>
            ref.read(navegacionProvider.notifier).ir(pestanas[i]),
        destinations: [for (final pestana in pestanas) _destino(pestana)],
      ),
    );
  }

  Widget _pantalla(Pestana pestana) => switch (pestana) {
    Pestana.canchas => const CanchasScreen(),
    Pestana.misReservas => const MisReservasScreen(),
    Pestana.admin => const AdminScreen(),
    Pestana.perfil => const PerfilScreen(),
  };

  NavigationDestination _destino(Pestana pestana) => switch (pestana) {
    Pestana.canchas => const NavigationDestination(
      icon: Icon(Icons.sports_soccer_outlined),
      selectedIcon: Icon(Icons.sports_soccer),
      label: 'Canchas',
    ),
    Pestana.misReservas => const NavigationDestination(
      icon: Icon(Icons.event_note_outlined),
      selectedIcon: Icon(Icons.event_note),
      label: 'Mis reservas',
    ),
    Pestana.admin => const NavigationDestination(
      icon: Icon(Icons.admin_panel_settings_outlined),
      selectedIcon: Icon(Icons.admin_panel_settings),
      label: 'Admin',
    ),
    Pestana.perfil => const NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  };
}
