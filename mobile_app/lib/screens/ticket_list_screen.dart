import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'create_ticket_screen.dart';
import 'ticket_detail_screen.dart';

/// Pantalla: TicketListScreen
/// --------------------------
/// Dashboard principal de la aplicación.
/// Muestra el listado de todos los tickets existentes y permite la navegación
/// hacia el detalle o la creación de nuevos registros.
///
class TicketListScreen extends StatefulWidget {
  // ID del usuario logueado (UUID). Necesario para crear nuevos tickets.
  final String userId;
  // Nombre real del usuario para mostrar en la interfaz.
  final String nombreUsuario;

  const TicketListScreen({
    super.key,
    required this.userId,
    required this.nombreUsuario, // Ahora es obligatorio recibir el nombre
  });

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  // Lista local para almacenar los tickets traídos de la API
  List<Ticket> misTickets = [];

  // Controla el estado de carga inicial
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTickets();
  }

  /// Llama al servicio API para obtener la lista actualizada de tickets.
  void _cargarTickets() async {
    try {
      var ticketsTraidos = await ApiService.getTickets();

      setState(() {
        misTickets = ticketsTraidos;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Método auxiliar para refrescar la lista.
  void _refresh() {
    setState(() {
      isLoading = true;
    });
    _cargarTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // CAMBIO: Ahora mostramos el nombre real en lugar del ID
        title: Text('Hola, ${widget.nombreUsuario}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: misTickets.length,
              itemBuilder: (context, index) {
                final ticket = misTickets[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: Icon(
                      ticket.estado == 'Cerrado'
                          ? Icons.check_circle
                          : Icons.error,
                      color: ticket.estado == 'Cerrado'
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(ticket.titulo),
                    subtitle: Text("${ticket.autor} - ${ticket.estado}"),

                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TicketDetailScreen(ticket: ticket),
                        ),
                      );
                      _refresh();
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              // IMPORTANTE: Seguimos pasando el 'userId' (UUID) para la creación técnica del ticket
              builder: (context) => CreateTicketScreen(userId: widget.userId),
            ),
          );
          _refresh();
        },
      ),
    );
  }
}
