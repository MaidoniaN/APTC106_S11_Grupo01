import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import 'ticket_list_screen.dart';

/// Pantalla: LoginScreen
/// ---------------------
/// Pantalla de inicio de la aplicación encargada de la autenticación.
/// Su función principal es validar las credenciales del usuario contra el Backend
/// y obtener el ID de sesión necesario para las operaciones posteriores.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar el texto ingresado en los campos.
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  // Variable de estado para controlar la interfaz durante la petición de red.
  // Si es true, muestra un spinner y deshabilita el botón.
  bool _isLoading = false;

  /// Lógica de inicio de sesión
  /// ------------------------
  /// 1. Cierra el teclado.
  /// 2. Activa el estado de carga.
  /// 3. Llama al servicio de API.
  /// 4. Navega o muestra error según el resultado.
  void _iniciarSesion() async {
    // Cierra el teclado virtual si está abierto
    FocusScope.of(context).unfocus();

    // Actualizamos la UI para mostrar que estamos "pensando"
    setState(() {
      _isLoading = true;
    });

    // Llamada asíncrona al backend
    final usuarioId = await ApiService.login(
      _userController.text.trim(), // trim() elimina espacios accidentales
      _passController.text.trim(),
    );

    // Desactivamos el estado de carga
    setState(() {
      _isLoading = false;
    });

    // Si el login fue exitoso (usuarioId tiene valor)
    if (usuarioId != null) {
      if (context.mounted) {
        // Navegamos a la pantalla principal, reemplazando la actual (no se puede volver atrás)
        // IMPORTANTE: Pasamos el 'usuarioId' obtenido para mantener la sesión.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicketListScreen(userId: usuarioId),
          ),
        );
      }
    } else {
      // Si falló (usuarioId es null)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario o contraseña incorrectos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos Center y SingleChildScrollView para asegurar que el diseño
      // se vea bien en pantallas pequeñas y cuando sale el teclado.
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- LOGO / ICONO PRINCIPAL ---
              const Icon(Icons.support_agent, size: 80, color: Colors.blue),
              const SizedBox(height: 20),

              // --- TÍTULO ---
              const Text(
                'ServiceDesk Login',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // --- SUBTÍTULO / VERSIÓN ---
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Prototipo v2.0',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 8), // Pequeño espacio
                    const Icon(
                      FontAwesomeIcons.flask, // Icono de laboratorio
                      size: 20,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- CAMPO DE USUARIO ---
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // --- CAMPO DE CONTRASEÑA ---
              TextField(
                controller: _passController,
                obscureText: true, // Oculta los caracteres
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),

              // --- BOTÓN DE INGRESO ---
              SizedBox(
                width: double.infinity, // Ocupa todo el ancho disponible
                height: 50,
                child: ElevatedButton(
                  // Si _isLoading es true, onPressed es null (botón deshabilitado)
                  onPressed: _isLoading ? null : _iniciarSesion,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('INGRESAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
