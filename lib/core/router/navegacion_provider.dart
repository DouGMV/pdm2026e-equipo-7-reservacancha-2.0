import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pestañas de la barra inferior, en el mismo orden en que se muestran.
enum Pestana { canchas, misReservas, admin, perfil }

/// La pestaña activa es estado de la app: cualquier pantalla puede cambiarla
/// (por ejemplo "Ver canchas" en Mis reservas) sin recibir callbacks por
/// constructor.
final navegacionProvider = NotifierProvider<NavegacionController, Pestana>(
  NavegacionController.new,
);

class NavegacionController extends Notifier<Pestana> {
  @override
  Pestana build() => Pestana.canchas;

  void ir(Pestana pestana) => state = pestana;
}
