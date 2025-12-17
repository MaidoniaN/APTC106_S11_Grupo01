import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket_model.dart';

/// Clase de servicio: ApiService
/// -----------------------------
/// Esta clase actúa como el "puente" de comunicación entre el Frontend (Flutter)
/// y el Backend (Flask). Utiliza el paquete 'http' para enviar solicitudes
/// REST (GET, POST, PUT) y procesar las respuestas en formato JSON.
///
/// MODIFICADO: Adaptado para manejar IDs tipo UUID (String) y retornar nombre de usuario.
class ApiService {
  // Dirección base de la API.
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // ==========================================
  // 1. AUTENTICACIÓN (LOGIN)
  // ==========================================

  /// Envía las credenciales (usuario y contraseña) al servidor para validar el acceso.
  ///
  /// Retorna:
  /// - [Map<String, dynamic>] con {'id': ..., 'nombre': ...} si el login es exitoso.
  /// - [null] si las credenciales son incorrectas o hay error de conexión.
  // CAMBIO: Ahora retorna un Map para incluir el nombre, no solo el ID string.
  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    try {
      // Realizamos una petición POST enviando el cuerpo en formato JSON
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      // Código 200 significa "OK"
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // CAMBIO: Retornamos un paquete con ID y Nombre para la UI
        return {
          'id': data['id'].toString(),
          'nombre': data['usuario'].toString(), // Dato extra para el saludo
        };
      } else {
        // Códigos 401 (Unauthorized) o 500 (Server Error)
        return null;
      }
    } catch (e) {
      print("Error en login: $e");
      return null;
    }
  }

  // ==========================================
  // 2. OBTENCIÓN DE DATOS (READ)
  // ==========================================

  /// Solicita al backend el listado completo de tickets registrados.
  static Future<List<Ticket>> getTickets() async {
    try {
      // Petición GET simple
      final response = await http.get(Uri.parse('$baseUrl/tickets'));

      if (response.statusCode == 200) {
        // Decodificamos el JSON que viene como una Lista de Mapas
        List<dynamic> body = jsonDecode(response.body);

        // Transformamos cada elemento del mapa JSON en una instancia de la clase Ticket
        return body.map((dynamic item) => Ticket.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error al obtener tickets: $e");
      return [];
    }
  }

  // ==========================================
  // 3. CREACIÓN DE REGISTROS (CREATE)
  // ==========================================

  /// Envía una solicitud para crear un nuevo ticket en la base de datos.
  static Future<bool> createTicket(
    String titulo,
    String descripcion,
    String userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "titulo": titulo,
          "descripcion": descripcion,
          "usuario_id": userId, // Enviamos el UUID del usuario
        }),
      );

      // Código 201 significa "Created"
      return response.statusCode == 201;
    } catch (e) {
      print("Error al crear ticket: $e");
      return false;
    }
  }

  // ==========================================
  // 4. ACTUALIZACIÓN DE ESTADO (UPDATE)
  // ==========================================

  /// Cierra un ticket existente y agrega un comentario de solución.
  static Future<bool> closeTicket(String id, String comentario) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tickets/$id/cerrar'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"comentario": comentario}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error al cerrar ticket: $e");
      return false;
    }
  }
}
