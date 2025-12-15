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
class TicketListScreen extends StatefulWidget {
  // ID del usuario logueado.
  // Se recibe desde el Login y se debe preservar para pasarlo al formulario de creación.
  final int userId;

  const TicketListScreen({super.key, required this.userId});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  // Lista local para almacenar los tickets traídos de la API
  List<Ticket> misTickets = [];

  // Controla el estado de carga inicial (muestra spinner mientras sea true)
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Al cargar la pantalla por primera vez, pedimos los datos
    _cargarTickets();
  }

  /// Llama al servicio API para obtener la lista actualizada de tickets.
  void _cargarTickets() async {
    try {
      // Petición asíncrona GET
      var ticketsTraidos = await ApiService.getTickets();

      // Actualizamos el estado para redibujar la pantalla con los nuevos datos
      setState(() {
        misTickets = ticketsTraidos;
        isLoading = false; // Ocultamos el spinner
      });
    } catch (e) {
      print(e);
      // En caso de error, también quitamos el spinner para no bloquear la UI
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Método auxiliar para refrescar la lista.
  /// Se usa cuando volvemos de crear o cerrar un ticket, para reflejar los cambios.
  void _refresh() {
    setState(() {
      isLoading = true; // Volvemos a mostrar carga
    });
    _cargarTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- BARRA SUPERIOR ---
      appBar: AppBar(
        // Mostramos el ID del usuario como confirmación visual de la sesión
        title: Text('Hola usuario #${widget.userId}'),
        actions: [
          // Botón de Cerrar Sesión (Logout)
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // Navegamos al Login reemplazando la ruta actual (para no poder volver atrás)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),

      // --- CUERPO PRINCIPAL ---
      // Si está cargando, muestra el círculo giratorio. Si no, muestra la lista.
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: misTickets.length,
              itemBuilder: (context, index) {
                final ticket = misTickets[index];

                // Tarjeta visual para cada item
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    // Icono dinámico según estado:
                    // Verde/Check si está cerrado, Rojo/Alerta si está abierto.
                    leading: Icon(
                      ticket.estado == 'Cerrado'
                          ? Icons.check_circle
                          : Icons.error,
                      color: ticket.estado == 'Cerrado'
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(ticket.titulo),
                    // Subtítulo con Autor y Estado
                    subtitle: Text("${ticket.autor} - ${ticket.estado}"),

                    // Al tocar el ticket, vamos al detalle
                    onTap: () async {
                      // Usamos 'await' para esperar a que el usuario regrese de la pantalla de detalle
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TicketDetailScreen(ticket: ticket),
                        ),
                      );
                      // Al volver, refrescamos la lista por si el ticket fue cerrado
                      _refresh();
                    },
                  ),
                );
              },
            ),

      // --- BOTÓN FLOTANTE (CREAR) ---
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Navegamos al formulario de creación
          await Navigator.push(
            context,
            MaterialPageRoute(
              // Es CRUCIAL pasar el 'widget.userId' aquí para que el ticket tenga autor
              builder: (context) => CreateTicketScreen(userId: widget.userId),
            ),
          );
          // Al volver, refrescamos la lista para mostrar el nuevo ticket
          _refresh();
        },
      ),
    );
  }
}
