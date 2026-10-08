# ReservaCancha 2.0

Aplicación móvil para reservar canchas deportivas. Proyecto del curso **Programación de Dispositivos Móviles** — Universidad Mesoamericana, sede Quetzaltenango. Equipo 7.

## Equipo

| Integrante | Rol |
|---|---|
| Douglas Morales | Arquitectura / Líder técnico |
| Nathaly Reyes | Base de datos / Apoyo backend |
| Julian Eduardo | Desarrollo del backend |
| Angel Ovalle | Lógica del frontend |
| Marco Bolaños | Desarrollo del frontend UI |

Detalle de responsabilidades en [docs/ROLES.md](docs/ROLES.md).

## Stack

Flutter · Dart · Riverpod · go_router · Firebase (Authentication + Cloud Firestore) · GitHub Actions. Justificación en [docs/TECNOLOGIAS.md](docs/TECNOLOGIAS.md).

## Documentación

| Documento | Contenido |
|---|---|
| [docs/PLAN.md](docs/PLAN.md) | Fases, sprints y entregables |
| [docs/ROLES.md](docs/ROLES.md) | Roles, responsabilidades y asignación por sprint |
| [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) | Capas, estructura de carpetas, modelo de datos |
| [docs/TECNOLOGIAS.md](docs/TECNOLOGIAS.md) | Tecnologías y paquetes |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Flujo de Git, ramas, commits, PRs y revisión |
| [CLAUDE.md](CLAUDE.md) | Contexto e instrucciones para trabajar con Claude Code |
| [AGENTS.md](AGENTS.md) | Instrucciones para otros agentes de IA (Codex, Copilot, Cursor, etc.) |

## Cómo ejecutar el proyecto

Requisitos: Flutter (canal estable), Android Studio o VS Code, un emulador o dispositivo Android, Git.

```bash
git clone https://github.com/DouGMV/pdm2026e-equipo-7-reservacancha-2.0.git
cd pdm2026e-equipo-7-reservacancha-2.0
git checkout develop
flutter pub get
flutter run
```

Antes de abrir un PR, ejecutar localmente:

```bash
dart format .
flutter analyze
flutter test
```

## Versiones

Se usa versionado semántico. Cada sprint cerrado genera un tag (`v2.0.0-alpha.1`, `v2.0.0-alpha.2`, …) y la entrega final es `v2.0.0`. Las APK se publican en **Releases**.
