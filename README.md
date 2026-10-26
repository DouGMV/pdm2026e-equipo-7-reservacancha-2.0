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

## Funcionalidades

**Cliente**
- Registro e inicio de sesión con correo y contraseña (Firebase Authentication).
- Listado de canchas activas con foto, precio y filtro por deporte.
- Detalle de la cancha con los horarios libres de los próximos 7 días.
- Reserva de un bloque de una hora con confirmación. No puede haber dos reservas de la misma cancha, fecha y hora (transacción de Firestore).
- Mis reservas: historial y cancelación de reservas futuras.
- Perfil con los datos del usuario y cierre de sesión.

**Administrador** (pestaña Admin, solo visible con rol `admin`)
- Agregar, editar, activar o desactivar y eliminar canchas (con "Deshacer").
- Ver todas las reservas, filtrarlas por estado y eliminarlas (con "Deshacer").
- Cargar canchas de ejemplo en un proyecto vacío.

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

### Primer uso con Firebase: administrador y datos de prueba

1. Desplegar las reglas y los índices de Firestore (requiere Firebase CLI con acceso al proyecto `reservachancha`):
   ```bash
   firebase deploy --only firestore
   ```
2. Registrar en la app la cuenta que será administradora.
3. En [Firebase Console](https://console.firebase.google.com/) → Firestore → colección `usuarios` → documento con el `uid` de esa cuenta, cambiar el campo `rol` de `cliente` a `admin`. Las reglas no permiten que un usuario cambie su propio rol desde la app.
4. Cerrar sesión y volver a entrar: aparece la pestaña **Admin**.
5. En Admin → Gestión de canchas, con la lista vacía, tocar **Cargar canchas de ejemplo** (5 canchas de los 4 deportes).

Las credenciales del administrador se comparten dentro del equipo; no se publican en el repositorio.

Antes de abrir un PR, ejecutar localmente:

```bash
dart format .
flutter analyze
flutter test
```

## Versiones

Se usa versionado semántico. Cada sprint cerrado genera un tag (`v2.0.0-alpha.1`, `v2.0.0-alpha.2`, …) y la entrega final es `v2.0.0`. Las APK se publican en **Releases**.

Para publicar una versión, desde `main` actualizado:

```bash
git tag v2.0.0
git push origin v2.0.0
```

El workflow `.github/workflows/release.yml` compila el APK en GitHub Actions y lo adjunta al Release; no hace falta el Android SDK en la computadora. El APK se firma con la llave de depuración de Flutter: sirve para instalarlo en un teléfono (activando "orígenes desconocidos"), pero no para publicarlo en Google Play.
