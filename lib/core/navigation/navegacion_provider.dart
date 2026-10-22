import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pestañas de la barra principal de la app.
enum Pestana {
  inicio('Inicio', Icons.home_outlined, Icons.home),
  canchas('Canchas', Icons.sports_soccer_outlined, Icons.sports_soccer),
  reservas('Reservas', Icons.event_note_outlined, Icons.event_note),
  perfil('Perfil', Icons.person_outline, Icons.person);

  const Pestana(this.etiqueta, this.iconoInactivo, this.iconoActivo);

  /// Texto que aparece bajo el ícono en la barra.
  final String etiqueta;
  final IconData iconoInactivo;
  final IconData iconoActivo;
}

/// Controla la pestaña activa de la barra principal.
///
/// Vive en un provider para que cualquier pantalla pueda llevar al usuario a
/// otra pestaña cambiando el estado, sin pasar funciones por los
/// constructores: `ref.read(navegacionProvider.notifier).irA(Pestana.canchas)`.
class NavegacionNotifier extends Notifier<Pestana> {
  @override
  Pestana build() => Pestana.inicio;

  /// Cambia la pestaña activa.
  void irA(Pestana pestana) => state = pestana;
}

final navegacionProvider = NotifierProvider<NavegacionNotifier, Pestana>(
  NavegacionNotifier.new,
);
