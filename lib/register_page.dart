// Archivo: lib/register_page.dart
import 'package:flutter/material.dart';
import 'modelos.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userC = TextEditingController();
  final _passC = TextEditingController();

  void _registrar() {
    if (_userC.text.isNotEmpty && _passC.text.isNotEmpty) {
      bool yaExiste = usuariosRegistrados.any((u) => u.user == _userC.text);
      if (yaExiste) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ese nombre de usuario ya está en uso")),
        );
        return;
      }

      usuariosRegistrados.add(Usuario(_userC.text, _passC.text));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario registrado con éxito")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
                controller: _userC,
                decoration: const InputDecoration(labelText: "Nuevo Usuario")
            ),
            TextField(
                controller: _passC,
                decoration: const InputDecoration(labelText: "Nueva Contraseña")
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registrar,
              child: const Text("Registrar"),
            )
          ],
        ),
      ),
    );
  }
}