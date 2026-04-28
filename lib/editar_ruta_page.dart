import 'package:flutter/material.dart';
import 'modelos.dart';

class EditarRutaPage extends StatefulWidget {
  final int indexRuta; // Recibimos la posición exacta de la ruta en la lista

  const EditarRutaPage({super.key, required this.indexRuta});

  @override
  State<EditarRutaPage> createState() => _EditarRutaPageState();
}

class _EditarRutaPageState extends State<EditarRutaPage> {
  late TextEditingController nombreC;
  late TextEditingController horarioC;

  @override
  void initState() {
    super.initState();
    // Llenamos los campos con los datos actuales de la ruta
    nombreC = TextEditingController(text: rutasGlobales[widget.indexRuta].nombre);
    horarioC = TextEditingController(text: rutasGlobales[widget.indexRuta].horario);
  }

  @override
  void dispose() {
    nombreC.dispose();
    horarioC.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    if (nombreC.text.isEmpty || horarioC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Los campos no pueden estar vacíos"))
      );
      return;
    }

    setState(() {
      // Actualizamos los valores en la lista global
      rutasGlobales[widget.indexRuta].nombre = nombreC.text;
      rutasGlobales[widget.indexRuta].horario = horarioC.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ruta actualizada correctamente"))
    );

    // Regresamos a la pantalla anterior enviando un "true" para avisar que hubo cambios
    Navigator.pop(context, true);
  }

  void _eliminarRuta() {
    // Cuadro de diálogo de confirmación antes de borrar
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Eliminar Ruta"),
          content: const Text("¿Estás seguro de que deseas eliminar esta ruta de forma permanente?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  rutasGlobales.removeAt(widget.indexRuta); // Eliminamos de la lista
                });
                Navigator.pop(context); // Cierra el diálogo
                Navigator.pop(context, true); // Regresa al admin y avisa del cambio
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ruta eliminada"))
                );
              },
              child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C4043), // Fondo oscuro
      appBar: AppBar(
        title: const Text("Editar o Eliminar Ruta"),
        backgroundColor: const Color(0xFF4285F4),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Tarjeta con los campos de texto
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withOpacity(0.1), // Azul muy transparente
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF4285F4), width: 1),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: nombreC,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Nombre de la Ruta",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      icon: Icon(Icons.route, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: horarioC,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Horario",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      icon: Icon(Icons.access_time, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Botones de acción
            Row(
              children: [
                // Botón rojo para eliminar
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _eliminarRuta,
                    icon: const Icon(Icons.delete),
                    label: const Text("Eliminar"),
                  ),
                ),
                const SizedBox(width: 15),
                // Botón azul para guardar
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _guardarCambios,
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}