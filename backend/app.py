"""
ServiceDesk Backend API
-----------------------
Autor: [Tu Nombre / Grupo 01]
Fecha: Diciembre 2025
Descripción:
    Servidor API RESTful desarrollado en Flask.
    Este archivo contiene la configuración del servidor, la definición del modelo de datos
    (tablas) y los endpoints (rutas) que consumirá la aplicación móvil.
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os

# ==========================================
# 1. CONFIGURACIÓN DE LA APLICACIÓN
# ==========================================

app = Flask(__name__)

# CORS (Cross-Origin Resource Sharing) es fundamental cuando el frontend (App Móvil/Emulador)
# y el backend corren en puertos o dominios distintos. Aquí permitimos todas las conexiones.
CORS(app)

# Configuración de la Base de Datos SQLite.
# 'basedir' obtiene la ruta absoluta donde está este archivo app.py.
basedir = os.path.abspath(os.path.dirname(__file__))

# Definimos que la DB se guardará en un archivo local llamado 'gestion_tickets.db'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'gestion_tickets.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False # Desactivamos notificaciones pesadas de SQLAlchemy

# Inicializamos el objeto 'db' que gestionará todas las operaciones con la base de datos
db = SQLAlchemy(app)


# ==========================================
# 2. MODELOS DE BASE DE DATOS (ORM)
# ==========================================

class Usuario(db.Model):
    """
    Tabla 'usuarios': Almacena las credenciales y datos de las personas.
    Relación: Un usuario puede ser autor de múltiples tickets (1:N).
    """
    __tablename__ = 'usuarios'
    
    # Clave Primaria (Primary Key) autoincremental
    id = db.Column(db.Integer, primary_key=True)
    
    # Nombre de usuario único para el login
    username = db.Column(db.String(50), unique=True, nullable=False)
    password = db.Column(db.String(50), nullable=False) 
    nombre_completo = db.Column(db.String(100))
    
    # 'db.relationship' permite acceder a los tickets de un usuario fácilmente (ej: usuario.tickets).
    # 'backref' crea una propiedad virtual en la clase Ticket llamada 'creador'.
    tickets = db.relationship('Ticket', backref='creador', lazy=True)

class Ticket(db.Model):
    """
    Tabla 'tickets': Almacena la información de los incidentes reportados.
    Vinculada a un usuario específico mediante Clave Foránea.
    """
    __tablename__ = 'tickets'
    
    id = db.Column(db.Integer, primary_key=True)
    titulo = db.Column(db.String(100), nullable=False)
    descripcion = db.Column(db.Text, nullable=False)
    
    # Estado del ticket. Por defecto se crea como 'Abierto'.
    estado = db.Column(db.String(20), default='Abierto')
    
    # Guardamos la fecha como String para simplificar la visualización en Flutter
    fecha_creacion = db.Column(db.String(20))
    
    # Campo opcional (nullable=True) para guardar la solución al cerrar el ticket
    comentario_cierre = db.Column(db.Text, nullable=True)
    
    # Clave Foránea (Foreign Key): Enlaza este ticket con el ID de un usuario existente
    usuario_id = db.Column(db.Integer, db.ForeignKey('usuarios.id'), nullable=False)


# ==========================================
# 3. INICIALIZACIÓN Y DATOS DE PRUEBA
# ==========================================

def crear_datos_iniciales():
    """
    Función auxiliar que se ejecuta al iniciar la app.
    Crea las tablas si no existen e inserta usuarios de prueba (Seed Data).
    """
    with app.app_context():
        # Crea todas las tablas definidas en los modelos (Usuario, Ticket)
        db.create_all()
        
        # Verificamos si la tabla de usuarios está vacía para no duplicar datos
        if not Usuario.query.first():
            print("Inicializando sistema: Creando usuarios de prueba...")
            
            # Instanciamos los objetos Usuario
            admin = Usuario(username='admin', password='123', nombre_completo='Administrador')
            user1 = Usuario(username='dylan', password='123', nombre_completo='Dylan Gorosito')
            user2 = Usuario(username='soporte1', password='password1', nombre_completo='Soporte Técnico')
            
            # Guardamos en la base de datos
            db.session.add_all([admin, user1, user2])
            db.session.commit()
            print("Usuarios creados exitosamente.")


# ==========================================
# 4. ENDPOINTS DE LA API (RUTAS)
# ==========================================

@app.route('/api/login', methods=['POST'])
def login():
    """
    Ruta: /api/login
    Método: POST
    Función: Valida credenciales de usuario.
    Retorna: JSON con el ID del usuario si es correcto, o error 401 si falla.
    """
    # Obtenemos el JSON enviado por Flutter
    data = request.json
    usuario_env = data.get('username')
    password_env = data.get('password')
    
    # Buscamos un usuario que coincida exactamente en nombre y contraseña
    user_db = Usuario.query.filter_by(username=usuario_env, password=password_env).first()
    
    if user_db:
        # Si existe, retornamos sus datos clave (especialmente el ID)
        return jsonify({
            'mensaje': 'Login exitoso', 
            'usuario': user_db.nombre_completo,
            'id': user_db.id
        }), 200
        
    # Si no existe o la contraseña está mal
    return jsonify({'mensaje': 'Credenciales incorrectas'}), 401


@app.route('/api/tickets', methods=['GET'])
def get_tickets():
    """
    Ruta: /api/tickets
    Método: GET
    Función: Devuelve el listado completo de tickets.
    """
    # Consultamos TODOS los tickets de la base de datos
    tickets = Ticket.query.all()
    lista_tickets = []
    
    # Convertimos cada objeto de DB a un diccionario (JSON)
    for t in tickets:
        lista_tickets.append({
            'id': t.id,
            'titulo': t.titulo,
            'descripcion': t.descripcion,
            'estado': t.estado,
            'fecha': t.fecha_creacion,
            # Gracias a 'backref' podemos acceder al nombre del creador directamente
            'autor': t.creador.nombre_completo, 
            'comentario_cierre': t.comentario_cierre
        })
        
    return jsonify(lista_tickets)


@app.route('/api/tickets', methods=['POST'])
def create_ticket():
    """
    Ruta: /api/tickets
    Método: POST
    Función: Crea un nuevo ticket en la base de datos.
    """
    data = request.json
    
    # Generamos la fecha actual
    now = datetime.now()
    fecha_str = f"{now.year}-{now.month}-{now.day}"
    
    # Validamos que venga el ID del usuario, si no, asignamos el ID 1 por defecto
    user_id = data.get('usuario_id', 1) 

    # Creamos el objeto Ticket
    nuevo_ticket = Ticket(
        titulo=data['titulo'],
        descripcion=data['descripcion'],
        estado='Abierto',
        fecha_creacion=fecha_str,
        usuario_id=user_id
    )
    
    # Guardamos en la BD
    db.session.add(nuevo_ticket)
    db.session.commit()
    
    # Retornamos código 201 (Created)
    return jsonify({'mensaje': 'Ticket creado exitosamente'}), 201


@app.route('/api/tickets/<int:ticket_id>/cerrar', methods=['PUT'])
def close_ticket(ticket_id):
    """
    Ruta: /api/tickets/<id>/cerrar
    Método: PUT
    Función: Actualiza el estado de un ticket a 'Cerrado' y agrega un comentario.
    """
    # Buscamos el ticket por su ID (Primary Key)
    ticket = Ticket.query.get(ticket_id)
    data = request.json 
    
    if ticket:
        # Actualizamos los campos
        ticket.estado = 'Cerrado'
        ticket.comentario_cierre = data.get('comentario', 'Sin comentarios') 
        
        # Confirmamos cambios
        db.session.commit()
        return jsonify({'mensaje': 'Ticket cerrado'}), 200
    
    # Si el ticket no existe (ej: ID incorrecto)
    return jsonify({'mensaje': 'Ticket no encontrado'}), 404


# ==========================================
# 5. PUNTO DE ENTRADA (MAIN)
# ==========================================
if __name__ == '__main__':
    # Ejecutamos la carga inicial de datos antes de levantar el servidor
    crear_datos_iniciales()
    
    # Iniciamos el servidor Flask.
    # host='0.0.0.0' permite que sea accesible desde la red (necesario para el emulador).
    app.run(debug=True, host='0.0.0.0', port=5000)