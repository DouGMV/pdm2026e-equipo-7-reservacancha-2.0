import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reservacancha/core/router/app_router.dart';
import 'package:reservacancha/core/router/navegacion_provider.dart';
import 'package:reservacancha/features/admin/presentation/admin_reservas_providers.dart';
import 'package:reservacancha/features/auth/data/auth_repository_fake.dart';
import 'package:reservacancha/features/auth/data/auth_repository_provider.dart';
import 'package:reservacancha/features/auth/presentation/auth_providers.dart';
import 'package:reservacancha/features/canchas/domain/filtro_canchas.dart';
import 'package:reservacancha/features/canchas/presentation/admin_canchas_providers.dart';
import 'package:reservacancha/features/canchas/presentation/canchas_providers.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_fake.dart';
import 'package:reservacancha/features/reservas/data/reservas_repository_provider.dart';
import 'package:reservacancha/features/reservas/domain/reserva.dart';
import 'package:reservacancha/features/reservas/presentation/mis_reservas_providers.dart';

Reserva _reservaDe(String usuarioId, String id) => Reserva(
  id: id,
  canchaId: 'cancha-1',
  canchaNombre: 'Cancha Sintética 1',
  usuarioId: usuarioId,
  fecha: '2026-10-30',
  hora: 18,
  estado: EstadoReserva.confirmada,
  total: 150,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer contenedor;

  setUp(() {
    contenedor = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWith((ref) {
          final repositorio = AuthRepositoryFake(demora: Duration.zero);
          ref.onDispose(repositorio.dispose);
          return repositorio;
        }),
        reservasRepositoryProvider.overrideWith(
          (ref) => ReservasRepositoryFake(
            demora: Duration.zero,
            reservas: [
              _reservaDe('uid-admin', 'reserva-admin'),
              _reservaDe('uid-ana', 'reserva-ana'),
            ],
            usuarioActual: () => ref.read(sesionProvider).value?.uid ?? '',
          ),
        ),
      ],
    );
    addTearDown(contenedor.dispose);
    // El router es quien escucha la sesión y reinicia el estado del usuario.
    contenedor
      ..listen(appRouterProvider, (_, _) {})
      ..listen(misReservasProvider, (_, _) {});
  });

  Future<void> esperar() => Future<void>.delayed(Duration.zero);

  Future<void> iniciarSesion(String email, String contrasena) async {
    await contenedor
        .read(authControllerProvider.notifier)
        .iniciarSesion(email: email, contrasena: contrasena);
    await esperar();
  }

  Future<List<String>> idsDeMisReservas() async => [
    for (final reserva in await contenedor.read(misReservasProvider.future))
      reserva.id,
  ];

  test('el siguiente usuario no hereda reservas, filtros ni pestaña', () async {
    await esperar();
    await iniciarSesion('admin@correo.com', 'admin123');
    expect(await idsDeMisReservas(), ['reserva-admin']);

    contenedor.read(filtroListadoProvider.notifier).seleccionarDeporte('padel');
    contenedor
        .read(filtroCanchasProvider.notifier)
        .seleccionarDeporte('futbol');
    contenedor
        .read(filtroReservasProvider.notifier)
        .estado(EstadoReserva.cancelada);
    contenedor.read(navegacionProvider.notifier).ir(Pestana.perfil);

    await contenedor.read(authControllerProvider.notifier).cerrarSesion();
    await esperar();
    await iniciarSesion('ana@correo.com', 'secreta1');

    expect(await idsDeMisReservas(), ['reserva-ana']);
    expect(contenedor.read(filtroListadoProvider), const FiltroCanchas());
    expect(contenedor.read(filtroCanchasProvider), const FiltroCanchas());
    expect(contenedor.read(filtroReservasProvider), const FiltroReservas());
    expect(contenedor.read(navegacionProvider), Pestana.canchas);
  });

  test('si la sesión no cambia de usuario, los filtros se conservan', () async {
    await esperar();
    await iniciarSesion('ana@correo.com', 'secreta1');

    contenedor.read(filtroListadoProvider.notifier).seleccionarDeporte('padel');
    // Otra emisión con el mismo usuario (por ejemplo, al refrescar la sesión).
    contenedor.invalidate(sesionProvider);
    await esperar();

    expect(
      contenedor.read(filtroListadoProvider),
      const FiltroCanchas(deporte: 'padel'),
    );
  });
}
