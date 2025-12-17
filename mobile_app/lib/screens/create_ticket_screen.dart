import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Pantalla: CreateTicketScreen
/// ----------------------------
/// Formulario encargado de la creación de nuevos incidentes.
class CreateTicketScreen extends StatefulWidget {
  final String userId; // ID del usuario que está logueado actualmente.
  const CreateTicketScreen({super.key, required this.userId});
  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Ticket')),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- CAMPO 1: TÍTULO ---
              TextFormField(
                controller: tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 15),

              // --- CAMPO 2: DESCRIPCIÓN ---
              TextFormField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 20),

              // --- BOTÓN DE GUARDADO ---
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guardando...')),
                    );

                    // Llamada al Servicio (API)
                    // widget.userId es ahora un String, compatible con el nuevo ApiService
                    final exito = await ApiService.createTicket(
                      tituloController.text,
                      descController.text,
                      widget.userId,
                    );

                    if (!context.mounted) return;

                    if (exito) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al guardar')),
                      );
                    }
                  }
                },
                child: const Text('GUARDAR TICKET'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
