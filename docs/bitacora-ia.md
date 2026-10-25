# Bitácora de uso de IA

Cada uso de IA que termina en el repositorio se registra aquí (el más reciente arriba).
El objetivo no es justificar el uso, sino demostrar **criterio**:
qué especificaste, qué revisaste y qué rechazaste.

| Campo | Qué escribir |
|---|---|
| Fecha / autor | `2026-10-15 · @usuario` |
| Herramienta | Claude, Copilot, ChatGPT, Gemini… |
| Especificación | Qué pediste y con qué restricciones (pegar el prompt o resumirlo) |
| Resultado | Qué devolvió, en una frase |
| Aceptado | Qué quedó en el código y por qué |
| Rechazado / corregido | Qué cambiaste y por qué. **Esta es la columna más importante.** |
| Verificación | Cómo comprobaste que funciona (pruebas, dispositivo) |
| Commit / PR | Enlace |

## 2026-10-25 · @Lilfacce — Reiniciar los datos del usuario al cambiar la sesión (#55)

- **Herramienta:** Claude Code.
- **Especificación:** "Que `misReservasProvider` y los filtros (`filtroListadoProvider`, `filtroCanchasProvider`, `filtroReservasProvider`) se reinicien cuando cambia el usuario, con una prueba de dos usuarios seguidos que falle sin el cambio." Viene de la revisión del #45.
- **Resultado:** en el `ref.listen(sesionProvider)` del router, al cambiar el `uid` se invalidan los tres filtros (junto al reinicio de la pestaña del #44); 2 pruebas nuevas en `reinicio_por_sesion_test.dart`.
- **Aceptado:** reiniciar desde el listener del router, igual que la pestaña. Así las pruebas de pantallas que no sustituyen la autenticación siguen funcionando.
- **Rechazado / corregido:**
  - `misReservasProvider` ya dependía del `uid` desde el #41 (Firebase); no se cambió, pero la prueba lo cubre para que no se rompa.
  - Se descartó que cada filtro hiciera `watch` de la sesión: cuatro archivos de pruebas de pantallas tendrían que sustituir Firebase solo por eso.
  - Se agregó una prueba para que los filtros se conserven si la sesión vuelve a emitir con el **mismo** usuario.
- **Verificación:** `dart format .`, `flutter analyze` sin observaciones y 152 pruebas en verde. Prueba de mutación: sin las invalidaciones, la prueba de dos usuarios falla.
- **Commit / PR:** issue #55 (rama sobre `feature/44-pantalla-perfil`, depende del #54).

## 2026-10-25 · @Lilfacce — Pantalla de Perfil y cerrar sesión (#44)

- **Herramienta:** Claude Code.
- **Especificación:** "Hacer el issue #44 en `feature/44-pantalla-perfil`: mostrar nombre, correo, teléfono y rol desde `sesionProvider`, botón Cerrar sesión con confirmación que use `AuthController.cerrarSesion()`, estados de carga y error, pruebas con un repositorio de auth falso. Además, reiniciar la pestaña activa al cambiar de usuario (lo ofrecí en la revisión del #45)."
- **Resultado:** `PerfilScreen` con los datos, el diálogo de confirmación y el aviso si falla; el reinicio de la navegación en `app_router.dart`; 8 pruebas nuevas.
- **Aceptado:** reiniciar la pestaña desde el `ref.listen(sesionProvider)` que ya tenía el router, cuando cambia el `uid`; borrar `Proximamente`, que ya no usaba ninguna pantalla.
- **Rechazado / corregido:**
  - Se descartó que `navegacionProvider` hiciera `watch` de la sesión: cualquier prueba que lo usara sin sustituir la autenticación intentaría abrir Firebase.
  - Al cerrar sesión bien, el router quita la pantalla; usar `ref` después del `await` fallaba. Se comprueba `context.mounted` antes.
  - La prueba de error con Reintentar pasaba sin mostrar el error: el reintento automático de Riverpod en `sesionProvider` resolvía el segundo intento solo. La falla ahora dura hasta que la prueba la quita.
  - La prueba de la barra (#33) esperaba "Próximamente" en Perfil; ahora espera el botón Cerrar sesión.
- **Verificación:** `dart format .`, `flutter analyze` sin observaciones y 150 pruebas en verde. Prueba de mutación: sin el reinicio de la navegación, la prueba del flujo completo falla (el siguiente usuario entraba a Perfil).
- **Commit / PR:** issue #44.

## 2026-10-24 · @Lilfacce — Listado de canchas con tarjetas y filtro por deporte (#18)

- **Herramienta:** Claude Code.
- **Especificación:** "Terminar el issue #18 en `feat/18-listado-canchas`: tarjetas con imagen, nombre, deporte y precio con `formatearMoneda`, chips de filtro por deporte sobre `canchasProvider` y sus pruebas. Reutilizar lo hecho en el #31."
- **Resultado:** `CanchaCard`, el filtro del listado (`filtroListadoProvider`), `canchasProvider` dependiente del filtro, el vacío según el filtro y 3 pruebas nuevas.
- **Aceptado:** reutilizar `FiltroDeporteChips` y `FiltroCanchas` del #31; un filtro **separado** del de administración, para que cada pestaña conserve el suyo; mover `FiltroCanchasNotifier` a `canchas_providers.dart` para que el listado no dependa de los providers de admin.
- **Rechazado / corregido:**
  - Las canchas de ejemplo no tienen foto (`imagenUrl` vacío) y no hay assets. En lugar de inventar URLs externas, la tarjeta muestra el icono del deporte sobre el color del tema, y usa `Image.network` con `errorBuilder` cuando haya foto.
  - La prueba de la barra (#33) buscaba "el" `Scrollable` de `CanchasScreen`; con los chips hay dos. Se cambió por la lista vertical (`AxisDirection.down`), sin tocar lo que comprueba.
  - En un teléfono de 400 px, los chips de Voleibol y Pádel quedan fuera de la pantalla y la prueba no podía tocarlos. Se usa `ensureVisible` antes de tocar, como haría el usuario al desplazar los chips.
- **Verificación:** `dart format .`, `flutter analyze` sin observaciones y 76 pruebas en verde en local.
- **Commit / PR:** issue #18.

## 2026-10-22 · @NathalyR15 — Laboratorio S15 (repositorio de canchas en memoria: eliminar y restaurar)

- **Herramienta:** Claude (chat, paso a paso; no tengo Claude Code).
- **Especificación:** el prompt del equipo para Claude Code (parte de datos y lógica del issue #31), adaptado a una conversación en chat. Después de la actualización del equipo, mi parte quedó en implementar `eliminar` y `restaurar` en `canchas_repository_fake.dart` (donde estaba el `TODO(#31)`) y las pruebas unitarias del repositorio. Se trabajó sobre la rama `feat/31-filtro`, sin crear otra. No se tocó la pantalla, el router ni `adminCanchasProvider`.
- **Resultado:** `CanchasRepositoryFake` con una lista en memoria copiada de las 5 canchas de ejemplo; `eliminar` por id y `restaurar` en su posición original; `canchasRepositoryProvider` con una sola instancia; y 12 pruebas unitarias nuevas.
- **Aceptado:**
  - Lista en memoria con `Future.delayed`, tal como pedía el issue.
  - `restaurar` calcula la posición con el orden de la lista de ejemplo y no duplica si el id ya existe.
  - `eliminar` con un id inexistente lanza `StateError`, y las pruebas comprueban que la lista no cambia.
  - No hizo falta cambiar `canchas_screen_test.dart`: lo leí y ya trae `eliminar` y `restaurar` en su repositorio de prueba.
- **Rechazado / corregido:**
  - El primer plan de la IA creaba la rama `feat/31-filtro`, pero ya existía en GitHub. Hice `git fetch --prune` y `git switch` a la existente.
  - Al quitar `const` del constructor (ahora el repositorio tiene estado), el provider dejó de compilar: `The constructor being called isn't a const constructor`. Lo detecté en VS Code y quité el `const` del provider.
  - El comando `code ...` que me dio la IA para crear el archivo de pruebas solo abría una pestaña vacía y no lo creaba. Lo creé con `New-Item`.
  - Borré `test/features/canchas/data/.gitkeep`, porque la carpeta ya tiene un archivo real.
  - Me quedé con `StateError` para el id inexistente, sin definir una excepción propia, porque el contrato no la pide y no agregamos clases de más.
  - `dart format .` reformateó dos archivos, y los dejé así antes del commit.
- **Verificación:** `dart format .`, `flutter analyze` sin observaciones y `flutter test` con las 38 pruebas en verde. Corrí aparte las pruebas del repositorio (12 en verde) para confirmar que mi archivo se ejecutaba.
- **Commit / PR:** `eb80291`, issue #31.
---

## 2026-10-24 · @DouGMV — Conectar la app con Firebase (issue #5)

- **Herramienta:** Claude Code.
- **Especificación:** "Guiarme para crear el proyecto de Firebase (plan Spark), habilitar Authentication con correo y Firestore, conectar la app con `flutterfire configure`, publicar `firestore.rules` y los índices, e inicializar Firebase en `main.dart`."
- **Resultado:** proyecto `reservachancha`; `lib/firebase_options.dart`, `android/app/google-services.json` y el plugin de Google Services; `firebase.json`, `.firebaserc` y `firestore.indexes.json` para publicar reglas e índices con `firebase deploy --only firestore`; `fake_cloud_firestore` en `dev_dependencies` (aprobado por el líder técnico, es un paquete opcional de `docs/TECNOLOGIAS.md`).
- **Aceptado:** la base `(default)` en `nam5`, porque `FirebaseFirestore.instance` usa esa base y el plan Spark solo permite una.
- **Rechazado / corregido:** `flutterfire` no estaba en el PATH y la primera vez se ejecutó fuera del repositorio; se usó `dart pub global run flutterfire_cli:flutterfire` desde la carpeta del proyecto.
- **Verificación:** índices consultados con `firebase firestore:indexes`; `flutter analyze` sin observaciones y 73 pruebas en verde. La compilación de Android no se pudo probar en este equipo (sin Android SDK); queda para un emulador del equipo.
- **Commit / PR:** issue #5.

## 2026-10-22 · @DouGMV — Laboratorio S15, navegación con barra inferior

- **Herramienta:** Claude Code.
- **Especificación:** "Implementar el requisito 1 y 2 del laboratorio S15 (issue #30) adaptado a nuestro proyecto, que ya usa go_router: pestaña activa en un `Notifier`, pantallas en un `IndexedStack`, 'Próximamente' para lo que no existe y navegación desde otra pantalla cambiando el provider. Seguir el ejemplo de inkash (`s15-01-navegacion`)."
- **Resultado:** `navegacionProvider` (`Pestana`), `InicioShell` con `NavigationBar` e `IndexedStack` en la ruta `/`, pestaña Admin con accesos a Gestión de canchas y Reservas, `Proximamente` para Perfil, y 4 pruebas de widget.
- **Aceptado:** el `IndexedStack` dentro de la ruta `/` de go_router: cumple la rúbrica (pestaña en un provider) sin perder go_router para login, detalle y admin.
- **Rechazado / corregido:**
  - Se evaluó usar `StatefulShellRoute.indexedStack` de go_router; se descartó porque la pestaña no viviría en un provider, que es lo que pide la rúbrica.
  - `/mis-reservas` y `/perfil` dejaron de ser rutas sueltas: navegar a ellas mostraba la pantalla sin la barra. Ahora son pestañas.
  - "Ver canchas" en Mis reservas usaba `context.go`; se cambió por `navegacionProvider.notifier.ir(Pestana.canchas)`.
  - La prueba de scroll se verificó reemplazando temporalmente el `IndexedStack` por un cambio simple de pantalla: la prueba falla, así que sí protege el comportamiento.
- **Verificación:** `dart format`, `flutter analyze` sin observaciones y 26 pruebas en verde.
- **Commit / PR:** issue #30.
## 2026-10-22 · @Lilfacce — Laboratorio S15 (gestión de canchas: filtro y eliminar con Deshacer)

- **Herramienta:** Claude Code.
- **Especificación:** "Hacer mi parte del issue #31 en `feat/31-filtro`: `AdminCanchasScreen` con chips de deporte reutilizables, los estados de la S14, `Dismissible` con `key` = id que borra primero en el repositorio, SnackBar con Deshacer y las pruebas de widget. La capa de datos la hace Nathaly; usar los nombres acordados con ella."
- **Resultado:** la pantalla, `FiltroDeporteChips`, `MensajeConAccion` en `core/widgets`, `FiltroCanchas`, `filtroCanchasProvider`, `adminCanchasProvider` y 4 pruebas de widget.
- **Aceptado:** el filtro inmutable con `==`; los chips y el catálogo de deportes reutilizables para el #18; mover `MensajeConAccion` a `core/widgets` (se usa en dos pantallas).
- **Rechazado / corregido:**
  - El prompt que se le dio a Nathaly pedía `adminCanchasProvider` como `FutureProvider`. Con eso, al terminar de deslizar, la fila seguía en la lista hasta volver a consultar, y Flutter lanza "A dismissed Dismissible widget is still part of the tree". Se cambió a un `AsyncNotifier` con `eliminar` (borra en el repositorio dentro de `confirmDismiss`) y `quitarDeLaLista` (la quita de inmediato en `onDismissed`).
  - En nuestra versión de Flutter, un `SnackBar` con acción no se cierra solo (`persist` vale `true` si hay acción), así que el mensaje de Deshacer se quedaba para siempre. Se usó `persist: false`.
  - El repositorio en memoria (`eliminar` y `restaurar`) se dejó como pendiente para Nathaly, en lugar de que la IA hiciera también su parte.
- **Verificación:** `dart format .`, `flutter analyze` sin observaciones y 26 pruebas en verde en local.
- **Commit / PR:** issue #31.
## 2026-10-22 · @DouGMV — Laboratorio S15, reservas (admin) con filtro y eliminar con Deshacer

- **Herramienta:** Claude Code.
- **Especificación:** "Resolver el issue #32 (pareja Julian–Douglas; Angel no disponible): en `AdminReservasScreen`, filtro inmutable por estado en un `Notifier`, lista que hace `ref.watch` del filtro, estados de la S14, `Dismissible` con key = id que borra primero en el repositorio y SnackBar con Deshacer que restaura la reserva idéntica. Seguir el patrón de inkash (`s15-03-historial`, `s15-04-eliminar`) y comprobar que las pruebas detectan errores reales."
- **Resultado:** `ReservasRepository` con `obtenerReservas`, `eliminar` y `restaurar`; repositorio simulado sobre una lista en memoria; `FiltroReservas`, `filtroReservasProvider` y `reservasAdminProvider` (`AsyncNotifier`); la pantalla; `MensajeConAccion` en `core/widgets`; 5 pruebas de widget.
- **Aceptado:** el `AsyncNotifier` con `build` que observa el filtro y los métodos `eliminar` (quita la fila del estado solo si el repositorio respondió bien) y `restaurar` (vuelve a consultar con el filtro actual).
- **Rechazado / corregido:**
  - El borrado se eligió en las pantallas de **admin** y no en las del cliente: según `docs/ARQUITECTURA.md` y `firestore.rules`, el cliente cancela, solo el admin elimina.
  - `MensajeConAccion` ya estaba copiado en dos pantallas; en lugar de una tercera copia se creó en `core/widgets` (las otras dos se pueden migrar después).
  - El repositorio falso de la prueba de Mis reservas se cambió a `extends Fake implements ReservasRepository` para que no deje de compilar cada vez que crece el contrato.
  - Se verificó la prueba del filtro cambiando temporalmente `ref.watch` por `ref.read`: las dos pruebas del filtro fallan, así que sí comprueban que la lista depende del filtro.
  - **Detectado en la revisión de Marco, no por la IA:** en Flutter 3.47 un `SnackBar` con acción usa `persist: true` por defecto, así que el mensaje de Deshacer no se cerraba y el de un segundo borrado quedaba en cola. Se corrigió con `persist: false` y `hideCurrentSnackBar()`, y se agregaron pruebas que comprueban que el mensaje se cierra y que dos borrados seguidos muestran el segundo Deshacer (la prueba falla si se quita `persist: false`). Por sugerencia de la misma revisión, `restaurar` avisa si falla y la fila se quita en `onDismissed` para que se vea la animación.
  - Al revisar el #37 integrando #33 + #34 + #37 se comprobó que, con la barra del #33, la pestaña Mis reservas seguía mostrando la reserva eliminada (el `IndexedStack` la mantiene viva con su lista en caché). Se corrigió invalidando `misReservasProvider` al eliminar y restaurar, con una prueba que falla si se quita.
- **Verificación:** `dart format`, `flutter analyze` sin observaciones y 31 pruebas en verde. Limitación: con la lista en memoria, lo eliminado no sobrevive a cerrar la app (validación 6 del laboratorio); llegará con Firestore.
- **Commit / PR:** issue #32.

## 2026-10-15 · @Lilfacce — Laboratorio S14, Parte B (estados del listado de canchas)

- **Herramienta:** Claude Code.
- **Especificación:** "Resolver el issue #24 en la rama `feat/24-estados-canchas` desde `develop`: entidad, contrato, repositorio falso, `canchasProvider` sin reintento automático, `CanchasScreen` con los cuatro estados y la prueba error → Reintentar → datos, respetando `docs/ARQUITECTURA.md`."
- **Resultado:** la entidad `Cancha`, `CanchasRepository`, `CanchasRepositoryFake` con 5 canchas, `canchasRepositoryProvider`, `canchasProvider`, la pantalla y 4 pruebas de widget.
- **Aceptado:** la separación por capas, `retry: (_, _) => null` y un repositorio de prueba controlable (que puede fallar, quedar vacío o ser lento) inyectado con `overrideWithValue`.
- **Rechazado / corregido:**
  - Con `AsyncValue.when` por defecto, al tocar **Reintentar** el mensaje de error seguía visible hasta que llegaba la respuesta, y el botón parecía no hacer nada. Se usó `skipLoadingOnRefresh: false` y se agregó una prueba que comprueba que aparece el indicador de carga al reintentar.
  - El `canchasRepositoryProvider` se dejó en su propio archivo de `data/`, separado del repositorio falso, para que al llegar Firestore solo cambie esa línea.
  - Se dejaron fuera el filtro por deporte y la navegación al detalle, porque el issue los deja para el Sprint 1/2.
- **Verificación:** `dart format .`, `flutter analyze` sin observaciones y 14 pruebas en verde en local.
- **Commit / PR:** issue #24.

## 2026-10-15 · @DouGMV — Laboratorio S14, Parte B (estados de mis reservas)

- **Herramienta:** Claude Code.
- **Especificación:** "Resolver el issue #25 en la rama `feat/25-estados-mis-reservas` (Julian no pudo participar), con el mismo patrón que el PR #26 para que el proyecto sea consistente: entidad `Reserva`, contrato, repositorio falso, `misReservasProvider` sin reintento automático, `MisReservasScreen` con los cuatro estados y pruebas de widget. Comprobar que las pruebas detectan errores reales."
- **Resultado:** `Reserva` con `EstadoReserva`, `ReservasRepository`, `ReservasRepositoryFake`, `reservasRepositoryProvider`, `misReservasProvider`, la pantalla, `formatearHora` en `core/utils` y 8 pruebas nuevas.
- **Aceptado:** el patrón del #26; el estado como `enum` en el dominio (el modelo de `data/` hará la conversión desde el texto de Firestore); `formatearHora` en `core/utils` porque también la usará el detalle de cancha.
- **Rechazado / corregido:**
  - La primera versión de las pruebas **pasaba aunque se quitara `retry: (_, _) => null`** (se comprobó quitando la línea). Causa: `pumpAndSettle` adelanta el reloj mientras el indicador de carga anima, y en ese tiempo corren los 10 reintentos automáticos de Riverpod (11 llamadas al repositorio) hasta que se rinde y muestra el error. Se agregó una prueba que avanza solo 100 ms (menos que el primer reintento) y cuenta las llamadas: ahora falla si se quita la línea.
  - "Ver canchas" se prueba con un `GoRouter` mínimo dentro de la prueba, en lugar de la app completa, que arranca en `/login`.
  - `_MensajeConAccion` queda duplicado con el del #26; se propone moverlo a `core/widgets` cuando ambos estén integrados.
- **Verificación:** `dart format`, `flutter analyze` sin observaciones y 18 pruebas en verde; prueba de mutación (quitar `retry`) detectada por la prueba nueva.
- **Commit / PR:** issue #25.

## 2026-10-15 · @DouGMV — Laboratorio S14, Parte A (CI, CODEOWNERS y bitácora)

- **Herramienta:** Claude Code.
- **Especificación:** "Adaptar de inkash (tag `s14-06-ci`) `ci.yml`, la plantilla de PR, `CODEOWNERS` y el formato de la bitácora a nuestro proyecto, respetando `CONTRIBUTING.md` y `docs/ROLES.md`. Detenerse antes de cada push."
- **Resultado:** los cuatro archivos de este PR y el plan del laboratorio.
- **Aceptado:** el check "Formato, análisis y pruebas", `workflow_dispatch`, `concurrency` y `timeout-minutes`; los puntos nuevos de la plantilla; esta bitácora.
- **Rechazado / corregido:**
  - Se quitó el paso de SQLite de inkash: no usamos `sqflite`. Tampoco se copió el job del APK por ahora, para que el CI de cada PR siga siendo rápido.
  - La IA advirtió que, al renombrar el check, las protecciones de `main` y `develop` seguirían esperando `analyze-and-test` y los PRs quedarían trabados: se actualiza el check requerido al integrar.
  - `CODEOWNERS` con solo `@DouGMV` en las áreas generales dejaba sus propios PRs sin quién los aprobara. Se decidió que cualquier integrante pueda aprobar esas áreas.
  - El laboratorio pide el PR directo a `main`, pero `CONTRIBUTING.md` solo permite `release/*`. Se eligió un flujo tipo *hotfix*: `chore/ci` → `main` y luego `main` → `develop`.
- **Verificación:** `dart format`, `flutter analyze` y `flutter test` en local antes del push, y el check en verde en el PR.
- **Commit / PR:** issue #21.

## 2026-10-08 · @DouGMV — Revisión de Pull Requests con apoyo de IA

- **Herramienta:** Claude Code.
- **Especificación:** "Revisar el PR contra `CONTRIBUTING.md`, `docs/ARQUITECTURA.md` y el issue; comprobar con pruebas antes de afirmar un error; redactar el comentario para que yo lo apruebe antes de publicarlo."
- **Resultado:** revisiones de #11, #14, #16, #19 y #20.
- **Aceptado:** los comentarios publicados, después de leerlos y ajustarlos.
- **Rechazado / corregido:**
  - En #16 la IA sospechó que `Size.fromHeight(48)` en el tema daba ancho infinito a todos los botones. No se publicó hasta comprobarlo con una prueba temporal (`BoxConstraints forces an infinite width` dentro de un `Row`).
  - En #19 sospechó que `int.tryParse` aceptaba teléfonos inválidos. Se verificó con un script: `-5551234`, `+5551234` y `0x123456` pasaban la validación.
  - En #19 la IA propuso dos caminos para los validadores duplicados. Douglas eligió pedir a Marco que los extrajera a `core/utils` en el mismo PR y aceptar las pantallas como versión provisional hasta tener el diseño en Figma.
- **Verificación:** pruebas temporales fuera del repositorio y CI de cada PR.

## 2026-10-08 · @DouGMV — Versión de Flutter en el CI y reglas de lint

- **Herramienta:** Claude Code.
- **Especificación:** "Fijar Flutter 3.47.6 en el CI y proponer reglas de `analysis_options.yaml` alineadas con `AGENTS.md`."
- **Resultado:** PR #15 (issue #13).
- **Aceptado:** `flutter-version: 3.47.6`, `strict-casts`, `strict-raw-types` y las reglas de estilo, `const` y código asíncrono.
- **Rechazado / corregido:** la regla `always_use_package_imports` marcó 12 imports relativos que la propia IA había escrito en la estructura base; se corrigieron con `dart fix --apply`.
- **Verificación:** `flutter analyze` sin observaciones y 6 pruebas en verde; el CI confirmó la versión 3.47.6.

## 2026-10-07 · @DouGMV — Inicialización del proyecto (Sprint 0)

- **Herramienta:** Claude Code.
- **Especificación:** "Ejecutar la tarea de inicialización de `CLAUDE.md` paso por paso, mostrar el plan antes de empezar y detenerse antes de cada push." Después: etiquetas, milestones, issues del Sprint 0, protección de ramas y tablero.
- **Resultado:** PR #1 (estructura base) e issues #4 a #9.
- **Aceptado:** la estructura feature-first, el router con las 9 rutas, el tema provisional y `formatters.dart` con su prueba.
- **Rechazado / corregido:**
  - El primer script para generar los archivos falló por un error de comillas; se rehízo y se verificó la estructura antes del commit.
  - La IA recomendó que la protección de ramas también aplicara al administrador. Douglas decidió poder saltarla mientras el equipo se integraba.
  - Los comandos de GitHub que propuso para PowerShell fallaron por el manejo de comillas; se reemplazaron por `gh project edit`.
  - El modo automático de la herramienta bloqueó los cambios de configuración del repositorio; Douglas los ejecutó manualmente.
- **Verificación:** `flutter analyze` sin observaciones, 6 pruebas en verde y CI en verde en el PR #1.

## 2026-10-24 · @AngelOvalle29 — Providers de sesión y redirección del router (#7)

- **Herramienta:** Claude (claude.ai).
- **Especificación:** "Con el issue #7, `docs/ARQUITECTURA.md` y el código actual de `develop`: contrato de `AuthRepository` en `domain/`, repositorio en memoria en `data/` (sin Firebase), `sesionProvider` y `AuthController` con Riverpod, `redirect` del router por sesión y rol, y pruebas. Sin paquetes nuevos y sin tocar `main.dart` para no chocar con el PR #41."
- **Resultado:** `AuthRepository`, `Usuario`, `AuthException`, `AuthRepositoryFake`, `sesionProvider`, `AuthController`, `calcularRedireccion` (función pura) y `refreshListenable` en `appRouterProvider`; login y registro conectados al provider; pruebas unitarias y de widgets.
- **Aceptado:** la separación por capas, que las pantallas no naveguen solas (decide el `redirect`) y la regla de redirección como función pura para probarla sin montar la app.
- **Rechazado / corregido:**
  - Al probar en el emulador encontré que un cliente que tocaba "Gestión de canchas" quedaba en una copia duplicada de `/` con una flecha que no funcionaba: el `push` se redirigía a `/`. La IA había propuesto dejar el filtro de la pestaña Admin para otro issue; se decidió incluirlo aquí y ocultar la pestaña a los clientes en `InicioShell`.
  - La prueba de registro usaba `ana@correo.com`, que ahora existe en el repositorio en memoria; se cambió a `luis@correo.com` y se agregó una prueba para el correo repetido.
  - En `app_router_test.dart` el helper de navegación usaba `GoRouter.of` desde un widget arriba de `MaterialApp.router` y fallaba con *No GoRouter found in context*; se cambió a leer `appRouterProvider` del contenedor de Riverpod.
- **Verificación:** `dart format .` sin cambios, `flutter analyze` sin observaciones y 98 pruebas en verde; probado a mano en el emulador (API 36) con las cuentas cliente y admin.
## 2026-10-25 · @DouGMV — Repositorios de Firebase (#49)

- **Herramienta:** Claude Code.
- **Especificación:** "Reemplazar los repositorios en memoria por Firebase Auth y Cloud Firestore solo en `data/`, sin tocar `domain/` ni las pantallas, y probar con `fake_cloud_firestore` y `mocktail`."
- **Resultado:** `AuthRepositoryFirebase`, `CanchasRepositoryFirestore`, `ReservasRepositoryFirestore` y sus modelos (`UsuarioModel`, `CanchaModel`, `ReservaModel`); los providers usan Firebase y las pruebas de la app completa usan los repositorios en memoria con `repositoriosEnMemoria()`.
- **Aceptado:** traducir los códigos de error de Firebase Auth a mensajes en español, ordenar las canchas en el cliente para no crear un índice por filtro y que "Mis reservas" se vuelva a consultar al cambiar de sesión.
- **Rechazado / corregido:**
  - Al cambiar los providers a Firebase fallaron las pruebas que montan `App` (Firebase no está inicializado en pruebas); se agregó el helper con overrides en lugar de condicionar el código de producción.
  - Al borrar una cancha en Admin, la pestaña Canchas seguía mostrando la lista vieja porque el `IndexedStack` la mantiene viva; ahora se invalida `canchasProvider`.
  - Faltaba un índice para "Todas" las reservas de Admin (orden por fecha y hora sin filtro) y la regla no dejaba al admin restaurar reservas de otros usuarios; se agregaron ambos.
- **Verificación:** `flutter analyze` sin observaciones y 115 pruebas en verde.

## 2026-10-25 · @DouGMV — Ver disponibilidad y reservar (#52)

- **Herramienta:** Claude Code.
- **Especificación:** "Detalle de cancha con fecha (7 días) y bloques de una hora, confirmación con el total y creación de la reserva en una transacción con id `{canchaId}_{yyyyMMdd}_{HH}`, como dice `docs/ARQUITECTURA.md`. Lógica de horarios en `domain/` para probarla sin Flutter."
- **Resultado:** `horarios.dart` (`idReserva`, `bloquesDelDia`, `proximosDias`), `SolicitudReserva`, `ReservaNoDisponibleException`, `obtenerCancha`, `obtenerHorasOcupadas` y `crearReserva` (Firestore y memoria), `ReservarController`, `DetalleCanchaScreen`, `ConfirmarReservaScreen` y la tarjeta del listado que abre el detalle.
- **Aceptado:** el reloj como provider (`relojProvider`) para probar "horas que ya pasaron" sin depender de la hora real, y que una hora elegida deje de contar como elegida si otra persona la reserva.
- **Rechazado / corregido:**
  - Los ids de ejemplo del repositorio en memoria tenían la hora sin cero (`_7`); la arquitectura pide `HH`, se corrigió a `_07`. La prueba de "otra persona ganó el horario" no fallaba por esa diferencia de id y así se detectó.
  - La prueba del flujo completo se quedaba colgada: esperaba un `Future.delayed` del repositorio dentro del reloj falso de `testWidgets`; se cambió a `tester.runAsync`.
  - En la pantalla de prueba de 800 × 600 la tarjeta quedaba fuera de vista; se usa un tamaño de teléfono (360 × 800).
- **Verificación:** `flutter analyze` sin observaciones y 142 pruebas en verde (incluye la transacción con `fake_cloud_firestore` y el flujo login → detalle → confirmar → Mis reservas).

## 2026-10-25 · @DouGMV — Crear, editar y desactivar canchas (#47) y datos de prueba (#48)

- **Herramienta:** Claude Code.
- **Especificación:** "Hacer el #47 y el #48 con los criterios de los issues: `crear`, `actualizar` y desactivar en los dos repositorios, formulario con validación, interruptor de activa, listado del cliente solo con canchas activas, y una forma de cargar datos de prueba en Firebase sin escribirlos a mano."
- **Resultado:** `CanchasRepository.crear`, `actualizar` y `cambiarActiva` (Firestore y memoria), `Cancha.copyWith`, `CanchaFormScreen` en `/admin/canchas/nueva` y `/admin/canchas/:id/editar`, interruptor en la lista de admin, botón "Cargar canchas de ejemplo" con la lista lista de `canchas_de_ejemplo.dart`, `validarPrecio` y la guía del README para crear el administrador.
- **Aceptado:** cargar los datos desde la app como admin en lugar de un script: no hace falta una cuenta de servicio ni credenciales fuera de la app, y las reglas de Firestore ya exigen ser admin para escribir canchas.
- **Rechazado / corregido:**
  - Un solo método `cambiarActiva` en lugar de `desactivar`, porque el interruptor también tiene que poder volver a activar.
  - La prueba de "el cierre debe ser después de la apertura" dependía de que el menú desplegable construyera la hora elegida, que no siempre está en pantalla; se quitó y la regla queda en el validador del formulario.
  - Crear el administrador sigue siendo manual en la consola: las reglas no dejan que nadie se dé el rol `admin` desde la app, y así debe quedar.
- **Verificación:** `flutter analyze` sin observaciones y 161 pruebas en verde.

## 2026-10-29 · @DouGMV — Prueba de la migración de esquema (Lab S16, #67)

- **Herramienta:** Claude Code.
- **Especificación:** "Hacer mi parte del #67: la prueba de migración con `fake_cloud_firestore` (base en versión 1 → migrar → datos iguales, `nombreNormalizado` y versión 2; migrar otra vez no cambia nada; una base en versión 2 no se toca). Julian todavía no subía el migrador: escribir la prueba primero y dejar el contrato definido para que él lo implemente."
- **Resultado:** `test/core/data/migrador_esquema_test.dart` con 5 pruebas y el esqueleto de `MigradorEsquema` (`leerVersion`, `migrar`, `versionActual`) con `UnimplementedError`, que Julian implementó en el #66.
- **Aceptado:** escribir la prueba antes que el código (las 5 fallaban hasta que llegó el migrador) y probar la idempotencia comparando todos los documentos completos, no solo el campo nuevo.
- **Rechazado / corregido:**
  - La IA propuso implementar también el migrador; se descartó porque el laboratorio pide que cada integrante haga su parte. Solo se usó una implementación temporal en local, que no se subió, para comprobar que la prueba estaba bien escrita.
  - Se agregó el caso "una base ya en versión 2 no se toca", con canchas sin `nombreNormalizado` a propósito: sin él, un migrador que ignorara la versión también pasaría las demás pruebas.
- **Verificación:** con el migrador de Julian, las 5 pruebas pasan sin cambiarlas; suite completa con 174 pruebas en verde y `flutter analyze` sin observaciones.
