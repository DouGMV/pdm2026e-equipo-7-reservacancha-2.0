# Tecnologías

## Stack principal

| Área | Tecnología | Por qué |
|---|---|---|
| Framework | Flutter (canal estable) + Dart | Requisito del curso; una sola base de código para Android (e iOS opcional). |
| Estado e inyección de dependencias | `flutter_riverpod` | Separa la lógica de la UI, facilita probar sin Firebase y no depende del `BuildContext`. |
| Navegación | `go_router` | Rutas declarativas y redirecciones automáticas según sesión y rol (cliente/admin). |
| Autenticación | `firebase_auth` | Registro e inicio de sesión con correo y contraseña sin construir un servidor propio. |
| Base de datos | `cloud_firestore` | Datos en tiempo real (disponibilidad actualizada al instante), transacciones para evitar reservas duplicadas, plan gratuito suficiente. |
| Configuración Firebase | `firebase_core` + FlutterFire CLI | Genera `firebase_options.dart` para conectar la app. |
| Fechas y moneda | `intl` | Formato de fechas en español y montos en quetzales (Q). |
| Calidad de código | `flutter_lints` | Reglas de estilo comunes para todo el equipo. |
| Pruebas | `flutter_test`, `mocktail` | Pruebas unitarias y de widgets con repositorios simulados. |

Opcionales (requieren aprobación del líder técnico antes de agregarse):
- `fake_cloud_firestore`: probar repositorios contra un Firestore simulado.
- `table_calendar`: calendario más visual que el `showDatePicker` nativo.
- `cached_network_image`: caché de imágenes de canchas.

## Herramientas del equipo

| Herramienta | Uso |
|---|---|
| GitHub | Repositorio, issues, PRs, Projects (tablero), Milestones (sprints), Releases |
| GitHub Actions | CI: formato, análisis estático y pruebas en cada PR |
| Figma | Wireframes y prototipo |
| Firebase Console | Administración de Auth, Firestore y reglas |
| VS Code / Android Studio | Desarrollo |

## Decisiones y restricciones

- **Plan de Firebase:** Spark (gratuito). No se usa Firebase Storage porque los buckets nuevos requieren el plan de pago; las imágenes de canchas se manejan como URL o como assets locales en el MVP.
- **Plataforma objetivo:** Android. iOS queda como extra.
- **Un solo proyecto de Firebase** compartido por todo el equipo. El archivo `firebase_options.dart` sí se sube al repositorio (no es un secreto; la seguridad está en las reglas de Firestore).
- **Agregar paquetes:** solo mediante PR, con justificación en la descripción, usando `flutter pub add <paquete>`.
- Todos usan la misma versión de Flutter. Verificar con `flutter --version` y anotarla en el issue de configuración del Sprint 0.
