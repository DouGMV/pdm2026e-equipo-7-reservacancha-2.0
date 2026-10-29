const _sinTilde = {
  'á': 'a',
  'à': 'a',
  'ä': 'a',
  'â': 'a',
  'ã': 'a',
  'é': 'e',
  'è': 'e',
  'ë': 'e',
  'ê': 'e',
  'í': 'i',
  'ì': 'i',
  'ï': 'i',
  'î': 'i',
  'ó': 'o',
  'ò': 'o',
  'ö': 'o',
  'ô': 'o',
  'õ': 'o',
  'ú': 'u',
  'ù': 'u',
  'ü': 'u',
  'û': 'u',
  'ñ': 'n',
  'ç': 'c',
};

/// Normaliza un nombre para compararlo: minúsculas, sin tildes y con un solo
/// espacio entre palabras. Por ejemplo `"  Cancha  Sintética 1 "` queda como
/// `"cancha sintetica 1"`.
String normalizarNombre(String texto) {
  final enMinusculas = texto.toLowerCase();
  final sinTildes = [
    for (final caracter in enMinusculas.split(''))
      _sinTilde[caracter] ?? caracter,
  ].join();
  return sinTildes.replaceAll(RegExp(r'\s+'), ' ').trim();
}
