import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateTicketScreen extends StatefulWidget {
  final int userId; // <--- Recibimos el ID

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
              TextFormField(
                controller: tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guardando...')),
                    );

                    // USAMOS EL ID REAL AQUÍ (widget.userId)
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
