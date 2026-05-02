import 'package:flutter/material.dart';
import 'modelos.dart';
import 'admin_page.dart';
import 'user_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  void _intentarLogin() {
    String user = _userController.text;
    String pass = _passController.text;

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("llena todos los campos")),
      );
      return;
    }

    if (user == 'admin' && pass == 'admin123') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminPage()),
      );
      return;
    }

    bool existe = usuariosRegistrados.any((u) => u.user == user && u.pass == pass);

    if (existe) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Credenciales incorrectas o usuario no existe"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_bus, size: 100, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Bustrack SV",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 40),
              TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: "Usuario",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  )
              ),
              const SizedBox(height: 16),
              TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  )
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _intentarLogin,
                  child: const Text("Iniciar Sesión", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage())
                  );
                },
                child: const Text("¿No tienes cuenta? Regístrate aquí", style: TextStyle(color: Colors.black)),
              )
            ],
          ),
        ),
      ),
    );
  }
}