import 'package:flutter/material.dart';
import 'modelos.dart';
import 'map_page.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rutas Disponibles"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: rutasGlobales.isEmpty
                ? const Center(child: Text("El administrador no ha publicado rutas aún."))
                : ListView.builder(
              itemCount: rutasGlobales.length,
              itemBuilder: (context, i) => ListTile(
                leading: const Icon(Icons.directions_bus, color: Colors.blue),
                title: Text(rutasGlobales[i].nombre),
                subtitle: Text("Horario: ${rutasGlobales[i].horario}"),
                trailing: const Icon(Icons.map, color: Colors.blueAccent),
                onTap: () {
                  // Al tocar una ruta, abrimos el mapa en modo usuario y le pasamos los datos
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(modoAdmin: false, rutaVisualizar: rutasGlobales[i]),
                      )
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Abrimos el mapa solo para ver la ubicación, sin cargar ninguna ruta
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapPage(modoAdmin: false))
                );
              },
              icon: const Icon(Icons.my_location),
              label: const Text("Explorar Mapa Libremente"),
            ),
          ),
        ],
      ),
    );
  }
}