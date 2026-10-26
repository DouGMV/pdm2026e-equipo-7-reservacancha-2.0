import 'package:flutter/material.dart';

/// Deportes de las canchas: valor guardado en Firestore → nombre para mostrar.
const Map<String, String> deportes = {
  'futbol': 'Fútbol',
  'basquetbol': 'Básquetbol',
  'voleibol': 'Voleibol',
  'padel': 'Pádel',
};

String nombreDeporte(String deporte) => deportes[deporte] ?? deporte;

IconData iconoDeporte(String deporte) => switch (deporte) {
  'futbol' => Icons.sports_soccer,
  'basquetbol' => Icons.sports_basketball,
  'voleibol' => Icons.sports_volleyball,
  'padel' => Icons.sports_tennis,
  _ => Icons.stadium,
};
