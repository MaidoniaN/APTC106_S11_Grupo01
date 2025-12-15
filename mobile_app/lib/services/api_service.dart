import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket_model.dart';

class ApiService {
  // Asegúrate que esta IP sea correcta para tu emulador (10.0.2.2) o dispositivo físico
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // --- LOGIN ---
  static Future<int?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id']; // Retorna el ID real
      } else {
        return null;
      }
    } catch (e) {
      print("Error en login: $e");
      return null;
    }
  }

  // --- OBTENER TICKETS ---
  static Future<List<Ticket>> getTickets() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tickets'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Ticket.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error al obtener tickets: $e");
      return [];
    }
  }

  // --- CREAR TICKET (AHORA RECIBE USER ID) ---
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
          "usuario_id": userId, // <--- Aquí usamos el ID real
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error al crear ticket: $e");
      return false;
    }
  }

  // --- CERRAR TICKET CON COMENTARIO ---
  static Future<bool> closeTicket(int id, String comentario) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tickets/$id/cerrar'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "comentario": comentario, // Enviamos el texto al backend
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error al cerrar ticket: $e");
      return false;
    }
  }
}
