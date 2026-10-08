# CLAUDE.md — Guía para Claude Code

Este archivo da contexto a Claude Code para trabajar en este repositorio. Léelo completo antes de hacer cualquier cambio. Las reglas generales para cualquier agente están en `AGENTS.md` y también aplican aquí.

## Proyecto

**ReservaCancha 2.0**: app móvil Flutter para reservar canchas deportivas. Proyecto del equipo 7 del curso Programación de Dispositivos Móviles (Universidad Mesoamericana, Quetzaltenango).

Documentación obligatoria antes de programar:
- `docs/ARQUITECTURA.md`: capas, estructura de carpetas, rutas, modelo de datos y regla anti-duplicados.
- `docs/TECNOLOGIAS.md`: stack y paquetes permitidos.
- `CONTRIBUTING.md`: ramas, commits, PRs y Definition of Done.
- `docs/ROLES.md` y `docs/PLAN.md`: quién hace qué y en qué sprint.

## Reglas para Claude Code

1. **Nunca** hacer commit ni push directo a `main` o `develop`, salvo en la tarea de inicialización descrita abajo. Todo lo demás va en una rama `feature/`, `fix/` o `docs/` según `CONTRIBUTING.md`.
2. Commits en formato `tipo(alcance): descripción` en español y en minúsculas.
3. Respetar la arquitectura por capas: Firebase solo se usa dentro de `data/`; `domain/` es Dart puro; `presentation/` solo habla con providers.
4. No agregar paquetes fuera de `docs/TECNOLOGIAS.md` sin que el usuario lo autorice.
5. Antes de dar una tarea por terminada, ejecutar y dejar sin errores:
   ```bash
   dart format .
   flutter analyze
   flutter test
   ```
6. Nombres de archivos en `snake_case`; dominio en español (`Cancha`, `Reserva`), sufijos técnicos en inglés (`Screen`, `Repository`, `Provider`).
7. No modificar los archivos de `docs/`, `CONTRIBUTING.md`, `AGENTS.md`, `firestore.rules` ni `.github/` salvo que el usuario lo pida.
8. Cuando haya dudas sobre alcance o diseño, preguntar al usuario en lugar de suponer.

## Tarea de inicialización (Sprint 0)

Ejecutar solo si el repositorio todavía no tiene `pubspec.yaml`. Esta tarea la dirige Douglas (Arquitectura).

### Paso 1 — Subir la documentación a `main`
```bash
git add .
git commit -m "docs: agregar documentación base del proyecto"
git push origin main
git checkout -b develop
git push -u origin develop
```

### Paso 2 — Rama de estructura base
```bash
git checkout develop
git checkout -b feature/1-estructura-base
```

### Paso 3 — Crear el proyecto Flutter en la raíz del repositorio
```bash
flutter create --org com.equipo7 --project-name reservacancha --platforms android,ios .
```
`flutter create` no sobrescribe archivos existentes, pero verifica que `README.md` siga siendo el del equipo. Si fue reemplazado, restáuralo con `git checkout -- README.md`.

### Paso 4 — Dependencias
```bash
flutter pub add flutter_riverpod go_router firebase_core firebase_auth cloud_firestore intl
flutter pub add --dev mocktail
```
`flutter_lints` ya viene incluido por `flutter create`.

### Paso 5 — Estructura de carpetas
Crear la estructura de `docs/ARQUITECTURA.md`:
```
lib/
├── main.dart
├── app.dart
├── core/{constants,errors,router,theme,utils,widgets}/
└── features/{auth,canchas,reservas,perfil,admin}/{data,domain,presentation}/
test/  (misma estructura que lib/)
```
Git no guarda carpetas vacías: en cada carpeta sin archivos agregar un `.gitkeep`.

### Paso 6 — Código base mínimo
- `main.dart`: `WidgetsFlutterBinding.ensureInitialized()` y `runApp(const ProviderScope(child: App()))`. **No** inicializar Firebase todavía: `firebase_options.dart` lo generará Nathaly con `flutterfire configure`. Dejar un comentario `// TODO(sprint-0): inicializar Firebase cuando exista firebase_options.dart`.
- `app.dart`: `MaterialApp.router` con el tema de `core/theme/app_theme.dart` y el router de `core/router/app_router.dart`.
- `core/theme/app_theme.dart`: `ThemeData` con Material 3 y un `ColorScheme.fromSeed` provisional (Marco lo reemplazará con la guía visual).
- `core/router/app_router.dart`: provider de `GoRouter` con las rutas de `docs/ARQUITECTURA.md`, cada una apuntando a una pantalla provisional.
- Una pantalla provisional por ruta en el `presentation/` de su funcionalidad (por ejemplo `features/auth/presentation/login_screen.dart`), que solo muestre un `Scaffold` con el nombre de la pantalla.
- `core/constants/firestore_collections.dart`: constantes `usuarios`, `canchas`, `reservas`.
- `core/utils/formatters.dart`: formato de moneda en quetzales (`Q`) y fechas `yyyy-MM-dd`, con su prueba unitaria.

### Paso 7 — Pruebas
- Eliminar `test/widget_test.dart` generado por defecto.
- Agregar `test/app_test.dart` que verifique que la app arranca y muestra la pantalla inicial.
- Agregar la prueba de `formatters.dart`.

### Paso 8 — Verificar y subir
```bash
dart format .
flutter analyze
flutter test
git add .
git commit -m "chore: crear estructura base del proyecto flutter"
git push -u origin feature/1-estructura-base
```
Luego indicar al usuario que abra el PR hacia `develop` en GitHub con `Closes #1` en la descripción (si existe el issue #1). Si `gh` está instalado y autenticado, se puede crear con:
```bash
gh pr create --base develop --title "chore: crear estructura base del proyecto flutter" --body "Closes #1"
```

## Estado actual del proyecto

Actualizar esta sección al cerrar cada sprint.

- Sprint actual: 0 — Preparación
- Firebase: pendiente de configurar (responsable: Nathaly)
- Diseño en Figma: pendiente (responsable: Marco)
