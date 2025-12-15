import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../services/api_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  // Variable local para actualizar la UI sin salir de la pantalla
  late Ticket _ticketActual;
  bool _isClosing = false; // Para el loading del botón

  @override
  void initState() {
    super.initState();
    _ticketActual = widget.ticket;
  }

  // Función para mostrar el diálogo de cierre
  void _mostrarDialogoCierre() {
    final comentarioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar Ticket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Cerrar diálogo
                _ejecutarCierre(comentarioController.text);
              },
              child: const Text('CERRAR TICKET'),
            ),
          ],
        );
      },
    );
  }

  void _ejecutarCierre(String comentario) async {
    setState(() => _isClosing = true);

    final exito = await ApiService.closeTicket(_ticketActual.id, comentario);

    if (exito) {
      // Actualizamos el estado localmente para reflejar el cambio inmediato
      setState(() {
        _isClosing = false;
        // Creamos un nuevo objeto ticket con los datos actualizados
        _ticketActual = Ticket(
          id: _ticketActual.id,
          titulo: _ticketActual.titulo,
          descripcion: _ticketActual.descripcion,
          autor: _ticketActual.autor,
          estado: 'Cerrado', // Cambiamos estado
          fecha: _ticketActual.fecha,
          comentarioCierre: comentario, // Guardamos el comentario
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket cerrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
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
    final bool esCerrado = _ticketActual.estado == 'Cerrado';
    final Color colorEstado = esCerrado ? Colors.green : Colors.orange;

    return Scaffold(
      appBar: AppBar(title: Text('Ticket #${_ticketActual.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _ticketActual.titulo,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // CHIP DE ESTADO
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorEstado.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorEstado),
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

            _infoRow(Icons.person, "Autor:", _ticketActual.autor),
            const SizedBox(height: 10),
            _infoRow(Icons.calendar_today, "Fecha:", _ticketActual.fecha),
            const Divider(height: 30),

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

            // --- LÓGICA DE CIERRE ---
            if (esCerrado) ...[
              // Si está cerrado, mostramos el comentario de solución
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
                    Text(_ticketActual.comentarioCierre ?? "Sin comentarios."),
                  ],
                ),
              ),
            ] else ...[
              // Si está abierto, mostramos el botón
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isClosing ? null : _mostrarDialogoCierre,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
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
