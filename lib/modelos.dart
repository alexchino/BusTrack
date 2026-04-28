import 'package:latlong2/latlong.dart';

// Modelo de datos para las rutas
class RutaBus {
   String nombre;
   String horario;
  // NUEVO: Esta lista guardará todos los puntos que el administrador toque en el mapa
   List<LatLng> puntos;

  RutaBus(this.nombre, this.horario, this.puntos);
}

// Modelo de datos para los usuarios
class Usuario {
  final String user;
  final String pass;
  Usuario(this.user, this.pass);
}

// Listas globales en memoria
List<RutaBus> rutasGlobales = [];
List<Usuario> usuariosRegistrados = [];