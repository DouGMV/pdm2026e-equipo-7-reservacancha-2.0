import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reservacancha/core/navigation/navegacion_provider.dart';

/// Contenedor de las pestañas de la app.
///
/// Las pantallas viven en el [IndexedStack] que usa
/// [StatefulShellRoute.indexedStack], así cada una conserva su estado y su
/// posición de scroll al cambiar de pestaña. La pestaña activa se lee del
/// provider [navegacionProvider], que es la única fuente de verdad.
class ShellPrincipal extends ConsumerWidget {
  const ShellPrincipal({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pestanaActiva = ref.watch(navegacionProvider);

    // Cuando otra pantalla cambia el provider, la barra la sigue.
    ref.listen<Pestana>(navegacionProvider, (anterior, siguiente) {
      if (siguiente.index != navigationShell.currentIndex) {
        navigationShell.goBranch(siguiente.index);
      }
    });

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: pestanaActiva.index,
        onDestinationSelected: (indice) =>
            ref.read(navegacionProvider.notifier).irA(Pestana.values[indice]),
        destinations: [
          for (final pestana in Pestana.values)
            NavigationDestination(
              icon: Icon(pestana.iconoInactivo),
              selectedIcon: Icon(pestana.iconoActivo),
              label: pestana.etiqueta,
            ),
        ],
      ),
    );
  }
}
