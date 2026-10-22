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

---

## 2026-10-22 · @julianeduardo512-del — Laboratorio S15, Parte 2 (filtro y Deshacer)

- **Herramienta:** opencode (modelo big-pickle).
- **Especificación:** "Completar el laboratorio S15 en una rama apilada sobre `feature/navegacion-s15`: el filtro del listado es un objeto inmutable dentro de un `Notifier` y la lista se arma en un provider que lo escucha con `ref.watch`; borrar deslizando con `Dismissible` cuya key es el id, borrando primero en la base y devolviendo la fila si falla; el SnackBar ofrece «Deshacer» y restaura el registro idéntico. Mantener los cuatro estados del listado, mensajes en español y al menos una prueba por lógica nueva."
- **Resultado:** `FiltroReservas` y `EstadoFiltroReserva` en `domain/` con la regla `incluye`; `FiltroReservasNotifier` y `MisReservasController` (`AsyncNotifier`) con `eliminar`, `quitar` y `restaurar`; chips de estado y de mes en la pantalla; `Dismissible` con fondo de borrado, SnackBar flotante con «Deshacer» y aviso si el borrado falla; persistencia del repositorio falso en un JSON temporal para que el borrado sobreviva a cerrar la app; `formatearMes` en `core/utils` y 18 pruebas nuevas (49 en total).
- **Aceptado:** la regla del filtro vive en el dominio (`incluye`), así `data/` y `presentation/` la comparten y el día que llegue Firestore solo se traduce a una consulta. `MisReservasController` como `AsyncNotifier` para quitar y restaurar en la lista visible sin volver a pedirla al repositorio. El borrado en la base ocurre en `confirmDismiss`: si falla devuelve `false`, la fila vuelve y el registro queda intacto. La persistencia del fake en `Directory.systemTemp` se eligió porque Firestore aún no está configurado y permite comprobar el requisito de cerrar y abrir la app con una prueba de repositorio.
- **Rechazado / corregido:**
  - La primera versión quitaba la reserva del estado dentro de `confirmDismiss`; la fila desaparecía de golpe, sin animación de salida, y `onDismissed` ya no corría. Se separó en dos pasos: `eliminar` (base) en `confirmDismiss` y `quitar` (lista visible) en `onDismissed`.
  - Las pruebas de deslizar fallaban porque `confirmDismiss` espera al repositorio sin programar cuadros y `pumpAndSettle` se detenía antes de que respondiera. Se agregó un paso explícito de reloj en las pruebas, documentado en el helper `_deslizarParaBorrar`.
  - `valueOrNull` de Riverpod 2 no existe en Riverpod 3: se usa `AsyncValue.value`.
  - El filtro por texto libre se dejó fuera: suma un `TextField` que el diseño aún no define y el issue solo pide al menos un filtro. Se usan estado y mes, que además se combinan.
  - Al restaurar con otro filtro activo la reserva no debe reaparecer: `restaurar` comprueba `filtro.incluye` antes de insertarla y el listado sigue siendo coherente.
- **Verificación:** `dart format .`, `flutter analyze` sin observaciones y 49 pruebas en verde; la prueba de persistencia borra con una instancia del repositorio, crea otra sobre el mismo archivo (simula reabrir la app) y comprueba que la reserva sigue borrada y que «Deshacer» la restaura con todos sus campos.
- **Commit / PR:** rama `feature/filtro-deshacer-s15` (apilada sobre `feature/navegacion-s15`), PR hacia `develop` pendiente de revisión.

## 2026-10-22 · @julianeduardo512-del — Laboratorio S15, Parte 1 (navegación real)

- **Herramienta:** opencode (modelo big-pickle).
- **Especificación:** "Implementar la navegación del laboratorio S15 en el repositorio del equipo: la pestaña activa vive en un provider (Notifier) y las pantallas en un IndexedStack (o go_router, que ya usamos); desde otra pantalla se navega cambiando el provider, como «Ver todo» en Inicio, sin pasar funciones por constructores; ningún botón de la barra queda sin hacer nada y lo que aún no exista muestra «Próximamente». Respetar `docs/ARQUITECTURA.md`, no usar Firebase fuera de `data/` y agregar pruebas de widget."
- **Resultado:** `navegacionProvider` (`Notifier<Pestana>`), `ShellPrincipal` con `StatefulShellRoute.indexedStack`, `InicioScreen` con el resumen del mes, las últimas reservas y «Ver todo», Perfil con datos y salida a inicio de sesión, pantalla `ProximamenteScreen`, `MensajeConAccion` compartido en `core/widgets` y 9 pruebas nuevas (provider y shell).
- **Aceptado:** `StatefulShellRoute.indexedStack` de go_router en lugar de un `IndexedStack` propio, porque el proyecto ya navega con go_router y así se conserva el estado y el scroll de cada pestaña sin duplicar pantallas. El provider es la única fuente de verdad: la barra lo escribe y el shell lo escucha para cambiar de rama. Se movió el `_MensajeConAccion` duplicado a `core/widgets`, como quedó propuesto en la bitácora de la S14.
- **Rechazado / corregido:**
  - La primera versión puso un `IndexedStack` dentro de una sola ruta y dejó `/canchas`, `/mis-reservas` y `/perfil` como rutas aparte: había dos instancias de la misma pantalla y el botón «Ver canchas» del estado vacío cambiaba de ruta en vez de pestaña. Se reemplazó por una rama por pestaña y ese botón ahora cambia el provider.
  - Una prueba nueva falló porque el nombre de la cancha de la reserva de prueba coincidía con el de la lista de canchas. El diagnóstico (`Offstage` por rama en go_router) confirmó que el error era de los datos de la prueba, no de la app; se renombró la reserva de prueba.
  - El botón «Entrar» de `LoginScreen` no hacía nada; se agregó para poder recorrer la app mientras la autenticación real llega en el Sprint 1.
  - **No se modificó `docs/ARQUITECTURA.md`** (regla 6 de `AGENTS.md`) aunque su tabla de rutas ya no coincide (`/` ahora es Inicio y el listado quedó en `/canchas`). Se avisa al equipo para actualizarla en un PR de documentación.
- **Verificación:** `dart format .`, `flutter analyze` sin observaciones y 31 pruebas en verde; la prueba de scroll compara la posición antes y después de cambiar de pestaña.
- **Commit / PR:** rama `feature/navegacion-s15`, PR hacia `develop` pendiente de revisión.

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
