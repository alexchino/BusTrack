import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bustrack SV',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0), // Azul más profundo y moderno
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Le decimos que la primera pantalla sea el Login
      home: const LoginPage(),
    );
  }
}