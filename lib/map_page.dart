import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'modelos.dart';

class MapPage extends StatefulWidget {
  final bool modoAdmin; // Define si estamos dibujando (Admin) o solo viendo (Usuario)
  final RutaBus? rutaVisualizar; // La ruta a mostrar si es un usuario

  const MapPage({super.key, required this.modoAdmin, this.rutaVisualizar});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<LatLng> _puntosPoligono = [];
  LatLng? _miUbicacion;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Si somos un usuario viendo una ruta, cargamos los puntos previamente guardados
    if (!widget.modoAdmin && widget.rutaVisualizar != null) {
      _puntosPoligono = List.from(widget.rutaVisualizar!.puntos);
    }
    _obtenerUbicacion();
  }

  Future<void> _obtenerUbicacion() async {
    try {
      // 1. Verificamos si el GPS del celular está encendido
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Por favor, activa el GPS de tu dispositivo.")),
          );
        }
        return;
      }

      // 2. Verificamos los permisos de la app
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Permiso de ubicación denegado.")),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Los permisos están denegados permanentemente. Actívalos en Ajustes.")),
          );
        }
        return;
      }

      // Aviso visual de que estamos buscando la ubicación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Obteniendo ubicación actual..."), duration: Duration(seconds: 1)),
        );
      }

      // 3. Obtenemos la posición exacta
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _miUbicacion = LatLng(position.latitude, position.longitude);
      });

      // Movemos la cámara a la ubicación del usuario si no hay ruta trazada
      if (_puntosPoligono.isEmpty) {
        _mapController.move(_miUbicacion!, 14.0);
      } else if (!widget.modoAdmin) {
        // Si el usuario está viendo una ruta, enfocamos la cámara en el inicio de esa ruta
        _mapController.move(_puntosPoligono.first, 14.0);
      }

    } catch (e) {
      // Si ocurre un error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al obtener ubicación: $e")),
        );
      }
    }
  }

  // Se activa cada vez que el administrador toca el mapa
  void _alTocarMapa(TapPosition tapPosition, LatLng puntoGeografico) {
    if (widget.modoAdmin) {
      setState(() {
        _puntosPoligono.add(puntoGeografico);
      });
    }
  }

  // Permite al administrador borrar el último punto si se equivocó
  void _deshacerUltimoPunto() {
    if (_puntosPoligono.isNotEmpty) {
      setState(() {
        _puntosPoligono.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modoAdmin ? "Trazar Ruta en Mapa" : (widget.rutaVisualizar?.nombre ?? "Explorar Mapa")),
        backgroundColor: widget.modoAdmin ? Colors.orange : Colors.blue,
        actions: [
          if (widget.modoAdmin)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: _deshacerUltimoPunto,
              tooltip: "Deshacer último punto",
            ),
          if (widget.modoAdmin)
            IconButton(
              icon: const Icon(Icons.check, size: 30),
              onPressed: () {
                if (_puntosPoligono.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Debes tocar el mapa al menos 2 veces para trazar una ruta.")),
                  );
                  return;
                }
                Navigator.pop(context, _puntosPoligono);
              },
              tooltip: "Guardar Trazo",
            ),
        ],
      ),
      // Usamos un Stack para poner la tarjeta flotante sobre el mapa
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(13.4312, -87.9628),
              initialZoom: 14.0,
              onTap: _alTocarMapa,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tuapp.bustrack',
              ),

              if (_puntosPoligono.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _puntosPoligono,
                      strokeWidth: 5.0,
                      color: widget.modoAdmin ? Colors.orange : Colors.blueAccent,
                    ),
                  ],
                ),

              if (_miUbicacion != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _miUbicacion!,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_history, color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          ),

          // NUEVO: Tarjeta flotante que muestra el horario
          if (!widget.modoAdmin && widget.rutaVisualizar != null)
            Positioned(
              top: 15,
              left: 15,
              right: 15,
              child: SafeArea(
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions_bus, color: Colors.blue, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.rutaVisualizar!.nombre,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, thickness: 1),
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled, color: Colors.orange, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Horario: ${widget.rutaVisualizar!.horario}",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _obtenerUbicacion,
        backgroundColor: widget.modoAdmin ? Colors.orange : Colors.blue,
        child: const Icon(Icons.gps_fixed, color: Colors.white),
      ),
    );
  }
}