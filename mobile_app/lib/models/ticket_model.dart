class Ticket {
  final int id;
  final String titulo;
  final String descripcion;
  final String autor;
  final String estado;
  final String fecha;
  final String? comentarioCierre; // <--- Puede ser nulo si está abierto

  Ticket({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.autor,
    required this.estado,
    required this.fecha,
    this.comentarioCierre, // <--- Opcional en el constructor
  });

  // Este método convierte el Mapa (JSON) que llega de internet en un objeto Ticket útil
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      autor: json['autor'],
      estado: json['estado'],
      fecha: json['fecha'],
      // Mapeamos el nuevo campo
      comentarioCierre: json['comentario_cierre'],
    );
  }
}
