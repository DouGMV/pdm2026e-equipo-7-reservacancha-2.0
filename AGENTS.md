# AGENTS.md — Guía para agentes de IA

Instrucciones para cualquier agente de programación (Codex, Copilot, Cursor, Gemini, Windsurf, etc.) que trabaje en este repositorio. Léelo completo antes de hacer cambios.

## Proyecto

**ReservaCancha 2.0**: app móvil Flutter para reservar canchas deportivas. Proyecto del equipo 7 del curso Programación de Dispositivos Móviles (Universidad Mesoamericana, Quetzaltenango).

Documentación que el agente debe consultar:
- `docs/ARQUITECTURA.md`: capas, carpetas, rutas, modelo de datos y regla anti-duplicados de reservas.
- `docs/TECNOLOGIAS.md`: stack y paquetes permitidos.
- `CONTRIBUTING.md`: ramas, commits, PRs y Definition of Done.
- `docs/ROLES.md`: qué capa le corresponde a cada integrante.

## Stack

Flutter (canal estable) · Dart · `flutter_riverpod` · `go_router` · `firebase_auth` · `cloud_firestore` · `intl` · `mocktail` para pruebas.

## Comandos

```bash
flutter pub get          # instalar dependencias
flutter run              # ejecutar la app
dart format .            # formatear
flutter analyze          # análisis estático
flutter test             # pruebas
```

Los tres últimos deben pasar sin errores antes de cualquier commit. El CI de GitHub los ejecuta en cada PR.

## Arquitectura en resumen

Feature-first con tres capas por funcionalidad (`auth`, `canchas`, `reservas`, `perfil`, `admin`):

| Capa | Contenido | Regla |
|---|---|---|
| `presentation/` | Pantallas, widgets, providers | No importa Firebase. Solo usa providers. |
| `domain/` | Entidades y contratos de repositorios | Dart puro, sin Flutter ni Firebase. |
| `data/` | Modelos, datasources, implementaciones | Único lugar donde se usa Firebase. |

Elementos compartidos en `lib/core/` (`constants`, `errors`, `router`, `theme`, `utils`, `widgets`). Las pruebas en `test/` replican la estructura de `lib/`.

## Reglas obligatorias

1. **Nunca** hacer commit ni push a `main` o `develop`. Trabajar siempre en una rama `feature/<issue>-<descripcion>`, `fix/<issue>-<descripcion>` o `docs/<issue>-<descripcion>` creada desde `develop` actualizado.
2. Commits con formato `tipo(alcance): descripción` en español y minúsculas. Tipos: `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`.
3. Respetar las capas de la arquitectura. Nunca usar Firebase fuera de `data/`.
4. **Mantenerse dentro del alcance del issue** y de la capa del integrante que lo pide (ver tabla abajo). Si la tarea requiere cambiar código de otra capa, avisar al usuario en lugar de hacerlo por su cuenta.
5. No agregar paquetes que no estén en `docs/TECNOLOGIAS.md` sin autorización explícita del usuario.
6. No modificar `docs/`, `CONTRIBUTING.md`, `AGENTS.md`, `CLAUDE.md`, `firestore.rules`, `.github/` ni `pubspec.yaml` salvo que el usuario lo pida.
7. Toda lógica nueva (providers, repositorios, utilidades) lleva al menos una prueba.
8. Toda pantalla maneja los estados de carga, error y datos (`AsyncValue`).
9. Mensajes visibles al usuario en español. Nunca mostrar errores crudos de Firebase.
10. No dejar `print`, código comentado ni archivos temporales.
11. Ante dudas de alcance o diseño, preguntar al usuario en lugar de suponer.

## Convenciones de código

- Archivos y carpetas en `snake_case`; clases en `PascalCase`.
- Sufijos: `_screen.dart`, `_providers.dart`, `_model.dart`, `_repository.dart`, `_repository_impl.dart`.
- Dominio en español (`Cancha`, `Reserva`, `Usuario`); sufijos técnicos en inglés (`Screen`, `Repository`, `Provider`).
- Preferir widgets `const` y archivos pequeños: un widget público por archivo.
- Colecciones de Firestore desde `core/constants/firestore_collections.dart`, nunca como texto suelto.

## Áreas por integrante

| Integrante | Rol | Dónde trabaja normalmente |
|---|---|---|
| Douglas Morales | Arquitectura / Líder técnico | `lib/core/`, estructura general, CI, revisiones |
| Nathaly Reyes | Base de datos / Apoyo backend | Firebase Console, `firestore.rules`, `features/*/data/` |
| Julian Eduardo | Desarrollo del backend | `features/*/data/`, `features/*/domain/` |
| Angel Ovalle | Lógica del frontend | `features/*/presentation/*_providers.dart`, `core/router/` |
| Marco Bolaños | Frontend UI | `features/*/presentation/` (pantallas y widgets), `core/theme/`, `core/widgets/` |

## Flujo de trabajo para una tarea

```bash
git checkout develop
git pull origin develop
git checkout -b feature/<issue>-<descripcion>
# ...implementar...
dart format .
flutter analyze
flutter test
git add .
git commit -m "feat(<alcance>): <descripción>"
git push -u origin feature/<issue>-<descripcion>
```

Después, el integrante abre el PR hacia `develop` usando la plantilla, con `Closes #<issue>` en la descripción. El agente no debe fusionar PRs.

## Regla crítica de negocio

No pueden existir dos reservas confirmadas para la misma cancha, fecha y hora. El ID de cada reserva es `{canchaId}_{yyyyMMdd}_{HH}` y se crea dentro de una transacción de Firestore. Ver `docs/ARQUITECTURA.md` antes de tocar cualquier código de reservas.

## Estado actual

- Sprint actual: 0 — Preparación
- Firebase: pendiente de configurar. Mientras no exista `lib/firebase_options.dart`, no inicializar Firebase en `main.dart`.
