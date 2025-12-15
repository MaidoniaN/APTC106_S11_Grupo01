/// Clase de Modelo: Ticket
/// -----------------------
/// Esta clase define la estructura de datos principal de la aplicación.
/// Actúa como un contenedor (objeto) para transportar la información de un ticket
/// desde la respuesta JSON de la API hacia los widgets de la interfaz.
class Ticket {
  // Identificador único del ticket en la base de datos (Primary Key)
  final int id;

  // Título o asunto del incidente
  final String titulo;

  // Detalle extenso del problema reportado
  final String descripcion;

  // Nombre del creador del ticket (ej: "Dylan Gorosito").
  // Este dato ya viene procesado desde el backend gracias a la relación SQL.
  final String autor;

  // Estado actual: 'Abierto' o 'Cerrado'
  final String estado;

  // Fecha de creación en formato texto (YYYY-MM-DD)
  final String fecha;

  // Campo opcional (Nullable).
  // Solo tendrá valor si el estado es 'Cerrado'. Si está 'Abierto', será null.
  final String? comentarioCierre;

  // Constructor estándar de la clase.
  // 'required' obliga a que estos datos existan al crear el objeto.
  Ticket({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.autor,
    required this.estado,
    required this.fecha,
    this.comentarioCierre, // Opcional, no lleva 'required'
  });

  /// Factory Constructor: fromJson
  /// -----------------------------
  /// Este método es vital para la comunicación con APIs REST.
  /// Convierte un Map<String, dynamic> (el formato en que Dart recibe el JSON)
  /// en una instancia tipada de la clase [Ticket].
  ///
  /// Mapea las claves del JSON (snake_case del backend) a las propiedades
  /// de la clase (camelCase de Dart).
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      autor: json['autor'],
      estado: json['estado'],
      fecha: json['fecha'],
      // Mapeo seguro: si 'comentario_cierre' es null en el JSON, será null aquí.
      comentarioCierre: json['comentario_cierre'],
    );
  }
}
