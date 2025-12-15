import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket_model.dart';

/// Clase de servicio: ApiService
/// -----------------------------
/// Esta clase actúa como el "puente" de comunicación entre el Frontend (Flutter)
/// y el Backend (Flask). Utiliza el paquete 'http' para enviar solicitudes
/// REST (GET, POST, PUT) y procesar las respuestas en formato JSON.
class ApiService {
  // Dirección base de la API.
  // IMPORTANTE:
  // '10.0.2.2' es una IP especial reservada por el emulador de Android para
  // referirse al 'localhost' de la computadora donde se ejecuta el código.
  // Si se utiliza un celular físico, se debe cambiar a la IP local de tu PC (ej: 192.168.1.XX).
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // ==========================================
  // 1. AUTENTICACIÓN (LOGIN)
  // ==========================================

  /// Envía las credenciales (usuario y contraseña) al servidor para validar el acceso.
  ///
  /// Retorna:
  /// - [int] con el ID del usuario si el login es exitoso.
  /// - [null] si las credenciales son incorrectas o hay error de conexión.
  static Future<int?> login(String username, String password) async {
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
        return data['id']; // Extraemos y retornamos el ID real de la base de datos
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
  ///
  /// Retorna:
  /// - Una lista de objetos [Ticket] llena si la petición es exitosa.
  /// - Una lista vacía [] si ocurre algún error.
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
  ///
  /// Parámetros:
  /// - [titulo]: El asunto del problema.
  /// - [descripcion]: Detalle del incidente.
  /// - [userId]: El ID del usuario que está creando el ticket (Fundamental para la autoría).
  static Future<bool> createTicket(
    String titulo,
    String descripcion,
    int userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "titulo": titulo,
          "descripcion": descripcion,
          "usuario_id": userId, // Asignamos el ticket al usuario logueado
        }),
      );

      // Código 201 significa "Created" (Recurso creado exitosamente)
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
  /// Utiliza el verbo PUT ya que estamos modificando un recurso existente.
  static Future<bool> closeTicket(int id, String comentario) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tickets/$id/cerrar'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "comentario": comentario, // Enviamos el texto de cierre al backend
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error al cerrar ticket: $e");
      return false;
    }
  }
}
