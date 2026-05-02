import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert'; // Para decodificar el JSON de la ruta
import 'package:http/http.dart' as http; // Para la petición web

// Asegúrate de que el archivo editar_ruta_page.dart esté en la misma carpeta
import 'editar_ruta_page.dart'; // ¡Faltaba el punto y coma aquí!
import 'modelos.dart';
import 'map_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final origenC = TextEditingController();
  final destinoC = TextEditingController();

  // Controladores para la entrada manual
  final nombreC = TextEditingController();
  final horarioC = TextEditingController();

  List<LatLng> _puntosTemporales = [];

  // ========================================================
  // Consulta a OSRM para autocompletar la ruta
  // ========================================================
  Future<void> _obtenerRutaOSRM(LatLng inicio, LatLng fin) async {
    // OSRM usa el formato: longitud,latitud
    final url = 'http://router.project-osrm.org/route/v1/driving/${inicio.longitude},${inicio.latitude};${fin.longitude},${fin.latitude}?geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'];

        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final coordinates = geometry['coordinates'];

          List<LatLng> rutaAutocompletada = [];
          for (var coord in coordinates) {
            // OSRM devuelve [longitud, latitud], latlong2 usa (latitud, longitud)
            rutaAutocompletada.add(LatLng(coord[1], coord[0]));
          }

          setState(() {
            _puntosTemporales = rutaAutocompletada;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("¡Ruta calculada automáticamente por las calles!"))
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al calcular la ruta. Verifica tu conexión."))
        );
      }
    }
  }

  Future<void> _abrirMapaParaTrazar() async {
    final resultadoPuntos = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPage(modoAdmin: true)),
    );

    if (resultadoPuntos != null && resultadoPuntos is List<LatLng>) {
      if (resultadoPuntos.length >= 2) {
        LatLng origen = resultadoPuntos.first;
        LatLng destino = resultadoPuntos.last;

        setState(() {
          origenC.text = "Punto A (${origen.latitude.toStringAsFixed(4)}, ${origen.longitude.toStringAsFixed(4)})";
          destinoC.text = "Punto B (${destino.latitude.toStringAsFixed(4)}, ${destino.longitude.toStringAsFixed(4)})";
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Calculando la mejor ruta... espere un momento."))
        );

        await _obtenerRutaOSRM(origen, destino);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Debes marcar al menos 2 puntos (Origen y Destino) en el mapa."))
        );
      }
    }
  }

  void _guardarRutaFinal() {
    if (_puntosTemporales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Toca el mapa primero para definir los puntos!"))
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Detalles de la Ruta"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreC,
                decoration: const InputDecoration(
                  labelText: "Nombre de la Ruta",
                  hintText: "Ej. Ruta Universitaria",
                  icon: Icon(Icons.route),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: horarioC,
                decoration: const InputDecoration(
                  labelText: "Horario",
                  hintText: "Ej. 06:00 AM - 08:00 PM",
                  icon: Icon(Icons.access_time),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                if (nombreC.text.isEmpty || horarioC.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Por favor llena ambos campos"))
                  );
                  return;
                }

                setState(() {
                  rutasGlobales.add(RutaBus(
                      nombreC.text,
                      horarioC.text,
                      List.from(_puntosTemporales)
                  ));

                  origenC.clear();
                  destinoC.clear();
                  nombreC.clear();
                  horarioC.clear();
                  _puntosTemporales.clear();
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("¡Ruta guardada exitosamente!"))
                );
              },
              child: const Text("Guardar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C4043),
      appBar: AppBar(
        title: const Text("Gestión de Rutas"),
        backgroundColor: const Color(0xFF4285F4),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF4285F4),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(icon: const Icon(Icons.train, color: Colors.white54), onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.radio_button_unchecked, color: Colors.white, size: 16),
                        Container(height: 30, width: 2, color: Colors.white54),
                        const Icon(Icons.location_on, color: Colors.white, size: 20),
                      ],
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: origenC,
                            readOnly: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Elegir punto de partida...",
                              hintStyle: TextStyle(color: Colors.white54),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: destinoC,
                            readOnly: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Elegir destino...",
                              hintStyle: TextStyle(color: Colors.white54),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.swap_vert, color: Colors.white),
                      onPressed: () {
                        final temp = origenC.text;
                        origenC.text = destinoC.text;
                        destinoC.text = temp;
                      },
                    )
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4285F4),
                        ),
                        onPressed: _abrirMapaParaTrazar,
                        icon: const Icon(Icons.map),
                        label: const Text(" Tocar en el Mapa"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _guardarRutaFinal,
                        icon: const Icon(Icons.save),
                        label: const Text(" Guardar Ruta"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rutas Guardadas",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: rutasGlobales.length,
                      itemBuilder: (context, i) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4285F4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            title: Text(
                                rutasGlobales[i].nombre,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                            ),
                            subtitle: Text(
                              rutasGlobales[i].horario,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            // AQUÍ ESTÁ LA CORRECCIÓN DE SINTAXIS
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.directions_bus, color: Colors.white),
                                IconButton(
                                  icon: const Icon(Icons.more_vert, color: Colors.white),
                                  onPressed: () async {
                                    // Navegamos a EditarRutaPage y esperamos el resultado
                                    final cambiosRealizados = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditarRutaPage(indexRuta: i), // Pasamos la posición 'i'
                                        )
                                    );

                                    // Si regresó con 'true' (se editó o eliminó), refrescamos la lista
                                    if (cambiosRealizados == true) {
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Ruta eliminada")),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapPage(modoAdmin: false, rutaVisualizar: rutasGlobales[i]),
                                  )
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}