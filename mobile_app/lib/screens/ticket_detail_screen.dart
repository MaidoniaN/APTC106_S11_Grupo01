import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../services/api_service.dart';

/// Pantalla: TicketDetailScreen
/// ----------------------------
/// Muestra la información completa de un ticket específico.
///
/// Características principales:
/// 1. Visualización de metadatos (Autor, Fecha, Estado).
/// 2. Lógica interactiva para cerrar tickets abiertos.
/// 3. Actualización en tiempo real de la interfaz sin necesidad de recargar la pantalla anterior.
class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket; // Objeto Ticket con los datos pasados desde la lista.
  const TicketDetailScreen({super.key, required this.ticket});
  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  // Variable local 'copia' del ticket.
  // La usamos para poder modificar su estado (de Abierto a Cerrado) visualmente
  // dentro de esta misma pantalla sin tener que volver a consultar la API.
  late Ticket _ticketActual;

  // Controla si el botón de cerrar debe mostrar un spinner de carga.
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos la variable local con los datos que vienen del constructor
    _ticketActual = widget.ticket;
  }

  /// Muestra un cuadro de diálogo (Alert) solicitando la justificación del cierre.
  void _mostrarDialogoCierre() {
    // Controlador temporal para capturar el texto del diálogo
    final comentarioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar Ticket'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
            children: [
              const Text('Por favor ingresa la solución o motivo del cierre:'),
              const SizedBox(height: 10),
              TextField(
                controller: comentarioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Se reinició el servidor...',
                ),
              ),
            ],
          ),
          actions: [
            // Botón Cancelar: Cierra el diálogo sin hacer nada
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            // Botón Confirmar: Cierra el diálogo y ejecuta la lógica de negocio
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // 1. Cerrar el pop-up
                _ejecutarCierre(comentarioController.text); // 2. Procesar
              },
              child: const Text('CERRAR TICKET'),
            ),
          ],
        );
      },
    );
  }

  /// Lógica de negocio para cerrar el ticket.
  ///
  /// 1. Llama al servicio API (PUT).
  /// 2. Si es exitoso, actualiza el estado local (_ticketActual) para reflejar el cambio.
  /// 3. Muestra feedback al usuario.
  void _ejecutarCierre(String comentario) async {
    // Activamos el indicador de carga en el botón
    setState(() => _isClosing = true);

    // Llamada al Backend
    final exito = await ApiService.closeTicket(_ticketActual.id, comentario);

    if (exito) {
      // ACTUALIZACIÓN OPTIMISTA DE LA UI:
      // Reconstruimos el objeto Ticket local con los nuevos datos (Estado cerrado y comentario).
      // Esto hace que la pantalla se "pinte" de verde instantáneamente.
      setState(() {
        _isClosing = false;

        _ticketActual = Ticket(
          id: _ticketActual.id,
          titulo: _ticketActual.titulo,
          descripcion: _ticketActual.descripcion,
          autor: _ticketActual.autor,
          estado: 'Cerrado', // <--- Cambio forzado de estado
          fecha: _ticketActual.fecha,
          comentarioCierre:
              comentario, // <--- Guardamos lo que escribió el usuario
        );
      });

      // Verificamos 'mounted' antes de usar el contexto en operaciones asíncronas
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket cerrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Manejo de errores
      setState(() => _isClosing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al conectar con el servidor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Variables auxiliares para definir colores según el estado actual
    final bool esCerrado = _ticketActual.estado == 'Cerrado';
    final Color colorEstado = esCerrado ? Colors.green : Colors.orange;

    return Scaffold(
      appBar: AppBar(title: Text('Ticket #${_ticketActual.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TÍTULO DEL TICKET ---
            Text(
              _ticketActual.titulo,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // --- CHIP (ETIQUETA) DE ESTADO ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorEstado.withOpacity(0.1), // Fondo suave
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorEstado), // Borde sólido
              ),
              child: Text(
                _ticketActual.estado.toUpperCase(),
                style: TextStyle(
                  color: colorEstado,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- METADATOS (AUTOR Y FECHA) ---
            _infoRow(Icons.person, "Autor:", _ticketActual.autor),
            const SizedBox(height: 10),
            _infoRow(Icons.calendar_today, "Fecha:", _ticketActual.fecha),
            const Divider(height: 30),

            // --- DESCRIPCIÓN ---
            const Text(
              "Descripción del problema:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              _ticketActual.descripcion,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            // --- SECCIÓN CONDICIONAL (EL "CEREBRO" DE LA PANTALLA) ---
            // Aquí decidimos qué mostrar según el estado del ticket.
            if (esCerrado) ...[
              // CASO 1: TICKET CERRADO
              // Mostramos un panel verde con la solución final.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          "Solución / Cierre:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Usamos '??' por seguridad, aunque si está cerrado debería tener comentario
                    Text(_ticketActual.comentarioCierre ?? "Sin comentarios."),
                  ],
                ),
              ),
            ] else ...[
              // CASO 2: TICKET ABIERTO
              // Mostramos el botón grande para cerrar el ticket.
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isClosing ? null : _mostrarDialogoCierre,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  // Cambiamos el icono por un spinner si está cargando
                  icon: _isClosing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.lock_clock),
                  label: const Text("CERRAR TICKET"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Widget auxiliar para reutilizar código en las filas de información (Icono + Texto)
  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text("$label ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}
