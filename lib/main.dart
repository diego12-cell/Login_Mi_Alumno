import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar lo que escribas en las cajas de texto
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();
  bool cargando = false;

  // 1. FUNCIÓN DE INICIO DE SESIÓN (La que ya tenías funcionando)
  Future<void> iniciarSesion() async {
    setState(() => cargando = true);

    // Ojo: Asegúrate de que esta IP sea la misma de tu PC actual
    final url = Uri.parse('http://192.168.1.236/login_api/login_api.php');

    try {
      final respuesta = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario": usuarioController.text,
          "password": passwordController.text,
        }),
      ).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (respuesta.statusCode == 200) {
        final resultado = jsonDecode(respuesta.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado['message'] ?? 'Respuesta recibida')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  // 2. NUEVA FUNCIÓN DE REGISTRO (La que mandará los datos a guardar)
  Future<void> registrarUsuario() async {
    setState(() => cargando = true);

    // Apunta al nuevo archivo PHP que acabamos de crear en XAMPP
    final url = Uri.parse('http://192.168.1.236/login_api/registro_api.php');

    try {
      final respuesta = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario": usuarioController.text,
          "password": passwordController.text,
        }),
      ).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (respuesta.statusCode == 200) {
        final resultado = jsonDecode(respuesta.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['message']),
            backgroundColor: resultado['success'] == true ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login y Registro Escolar')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usuarioController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            cargando
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      // Botón para iniciar sesión
                      ElevatedButton(
                        onPressed: iniciarSesion,
                        child: const Text('Entrar'),
                      ),
                      const SizedBox(height: 10),
                      // Nuevo Botón para registrarse en la base de datos
                      OutlinedButton(
                        onPressed: registrarUsuario,
                        child: const Text('Registrarse'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
