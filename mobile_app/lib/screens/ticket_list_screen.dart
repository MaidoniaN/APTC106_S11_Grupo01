import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'create_ticket_screen.dart';
import 'ticket_detail_screen.dart';

class TicketListScreen extends StatefulWidget {
  final int userId; // <--- Variable para guardar el ID

  // Exigimos el ID en el constructor
  const TicketListScreen({super.key, required this.userId});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  List<Ticket> misTickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTickets();
  }

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
        title: Text('Hola usuario #${widget.userId}'), // Opcional: mostrar ID
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
              // PASAMOS EL ID AL FORMULARIO DE CREAR
              builder: (context) => CreateTicketScreen(userId: widget.userId),
            ),
          );
          _refresh();
        },
      ),
    );
  }
}
