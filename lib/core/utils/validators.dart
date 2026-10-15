/// Validadores de formularios (ver docs/ARQUITECTURA.md: van en core/utils/).
/// Base para las pantallas; Angel podrá ajustarlos en el Sprint 1.
library;

/// Devuelve [mensaje] si [valor] está vacío; si no, null.
String? validarRequerido(
  String? valor, {
  String mensaje = 'Este campo es obligatorio',
}) {
  if (valor == null || valor.trim().isEmpty) return mensaje;
  return null;
}

/// Correo obligatorio y con arroba.
String? validarCorreo(String? valor) {
  return validarRequerido(valor, mensaje: 'Introduce el correo electrónico') ??
      (valor!.trim().contains('@')
          ? null
          : 'Introduce un correo electrónico válido');
}

/// Contraseña obligatoria de al menos 6 caracteres.
String? validarContrasena(String? valor) {
  return validarRequerido(valor, mensaje: 'Introduce la contraseña') ??
      (valor!.length < 6
          ? 'La contraseña debe tener al menos 6 caracteres'
          : null);
}

/// Teléfono obligatorio: exactamente 8 dígitos.
String? validarTelefono(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return 'Introduce tu teléfono';
  final esOchoDigitos = texto.length == 8 && int.tryParse(texto) != null;
  return esOchoDigitos ? null : 'Introduce un teléfono válido (8 dígitos)';
}
