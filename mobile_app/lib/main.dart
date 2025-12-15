// lib/main.dart

import 'package:flutter/material.dart';
// Importamos la pantalla de Login, que será la primera que vea el usuario.
import 'screens/login_screen.dart';

/// Función principal (Entry Point) de Dart.
/// Aquí es donde comienza la ejecución del programa.
void main() {
  // runApp toma el widget raíz (ServiceDeskApp) y lo "infla" para que ocupe toda la pantalla.
  runApp(const ServiceDeskApp());
}

/// Widget Raíz de la Aplicación.
/// Es un StatelessWidget porque su configuración (tema, título, ruta inicial)
/// no cambia mientras la app está corriendo.
class ServiceDeskApp extends StatelessWidget {
  const ServiceDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp es el contenedor principal que provee la estructura de diseño Material Design.
    // Sin esto, no funcionaría la navegación, ni los TextFields, ni los Scaffolds.
    return MaterialApp(
      title: 'ServiceDesk Prototipo',

      // Oculta la etiqueta roja de "DEBUG" en la esquina superior derecha.
      // Es puramente estético para que el prototipo se vea más limpio al presentar.
      debugShowCheckedModeBanner: false,

      // --- CONFIGURACIÓN GLOBAL DEL TEMA ---
      // Aquí definimos los colores que usarán todos los widgets por defecto.
      theme: ThemeData(
        // Define el color primario (Azul). Los botones y barras de navegación heredarán esto.
        primarySwatch: Colors.blue,
        // Habilita la versión 3 de Material Design (botones más redondeados, nuevos colores).
        useMaterial3: true,
      ),

      // --- RUTA INICIAL ---
      // Indicamos qué widget mostrar primero.
      // Aquí conectamos con todo el trabajo que hicimos en 'screens/login_screen.dart'.
      home: const LoginScreen(),
    );
  }
}
