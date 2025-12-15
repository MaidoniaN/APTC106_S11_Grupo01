import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Pantalla: CreateTicketScreen
/// ----------------------------
/// Formulario encargado de la creación de nuevos incidentes.
///
/// Funcionalidad Principal:
/// 1. Renderiza un formulario con validación (Título y Descripción).
/// 2. Captura la entrada del usuario mediante controladores.
/// 3. Envía los datos al Backend utilizando el [userId] de la sesión actual.
class CreateTicketScreen extends StatefulWidget {
  // ID del usuario que está logueado actualmente.
  // Es vital recibir este dato para asociar el ticket al autor correcto en la base de datos.
  final int userId;

  const CreateTicketScreen({super.key, required this.userId});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  // Clave global para identificar el formulario y gestionar su estado (validaciones).
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para leer lo que escribe el usuario en los campos.
  final tituloController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con título
      appBar: AppBar(title: const Text('Nuevo Ticket')),

      // Cuerpo con padding para que no quede pegado a los bordes
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // Widget Form que habilita la validación de sus descendientes (TextFormField)
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- CAMPO 1: TÍTULO ---
              TextFormField(
                controller: tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                // Validador: Retorna un string con error si está vacío, o null si está bien.
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 15), // Espacio vertical
              // --- CAMPO 2: DESCRIPCIÓN ---
              TextFormField(
                controller: descController,
                maxLines: 3, // Campo más alto para escribir párrafos
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 20), // Espacio antes del botón
              // --- BOTÓN DE GUARDADO ---
              ElevatedButton(
                onPressed: () async {
                  // 1. Ejecutamos la validación de todos los campos del formulario
                  if (_formKey.currentState!.validate()) {
                    // Feedback visual inmediato para el usuario
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guardando...')),
                    );

                    // 2. Llamada al Servicio (API)
                    // Importante: Usamos 'widget.userId' para acceder a la variable definida
                    // en la clase superior (CreateTicketScreen).
                    final exito = await ApiService.createTicket(
                      tituloController.text,
                      descController.text,
                      widget.userId,
                    );

                    // Verificación de seguridad: Si el widget ya no existe (el usuario salió),
                    // detenemos la ejecución para evitar errores.
                    if (!context.mounted) return;

                    // 3. Manejo de la respuesta
                    if (exito) {
                      // Si se guardó, cerramos la pantalla y volvemos a la lista
                      Navigator.pop(context);
                    } else {
                      // Si falló, mostramos mensaje de error
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
