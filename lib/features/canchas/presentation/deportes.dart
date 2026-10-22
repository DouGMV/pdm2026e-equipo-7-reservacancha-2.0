/// Deportes de las canchas: valor guardado en Firestore → nombre para mostrar.
const Map<String, String> deportes = {
  'futbol': 'Fútbol',
  'basquetbol': 'Básquetbol',
  'voleibol': 'Voleibol',
  'padel': 'Pádel',
};

String nombreDeporte(String deporte) => deportes[deporte] ?? deporte;
