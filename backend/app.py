from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)

# --- CONFIGURACIÓN DE LA BASE DE DATOS ---
basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'gestion_tickets.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# --- MODELOS ---
class Usuario(db.Model):
    __tablename__ = 'usuarios'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password = db.Column(db.String(50), nullable=False)
    nombre_completo = db.Column(db.String(100))
    tickets = db.relationship('Ticket', backref='creador', lazy=True)

class Ticket(db.Model):
    __tablename__ = 'tickets'
    id = db.Column(db.Integer, primary_key=True)
    titulo = db.Column(db.String(100), nullable=False)
    descripcion = db.Column(db.Text, nullable=False)
    estado = db.Column(db.String(20), default='Abierto')
    fecha_creacion = db.Column(db.String(20))
    comentario_cierre = db.Column(db.Text, nullable=True)
    usuario_id = db.Column(db.Integer, db.ForeignKey('usuarios.id'), nullable=False)

# --- INICIALIZACIÓN ---
def crear_datos_iniciales():
    with app.app_context():
        db.create_all()
        
        # Verificar si existen usuarios, si no, los crea
        if not Usuario.query.first():
            print("Creando usuarios de prueba...")
            # Aquí agregamos al usuario 'soporte1'
            admin = Usuario(username='admin', password='123', nombre_completo='Administrador')
            user1 = Usuario(username='dylan', password='123', nombre_completo='Dylan Gorosito')
            user2 = Usuario(username='soporte1', password='password1', nombre_completo='Soporte Técnico')
            
            db.session.add(admin)
            db.session.add(user1)
            db.session.add(user2)
            db.session.commit()
            print("Usuarios creados exitosamente.")

# --- RUTAS (Ahora todas empiezan con /api) ---

@app.route('/api/login', methods=['POST']) # <--- CAMBIO AQUÍ
def login():
    data = request.json
    usuario = data.get('username')
    password = data.get('password')
    
    user_db = Usuario.query.filter_by(username=usuario, password=password).first()
    
    if user_db:
        return jsonify({
            'mensaje': 'Login exitoso', 
            'usuario': user_db.nombre_completo,
            'id': user_db.id
        }), 200
    return jsonify({'mensaje': 'Credenciales incorrectas'}), 401

# --- EN LA RUTA GET TICKETS (Para que devuelva el comentario) ---
@app.route('/api/tickets', methods=['GET'])
def get_tickets():
    tickets = Ticket.query.all()
    lista_tickets = []
    for t in tickets:
        lista_tickets.append({
            'id': t.id,
            'titulo': t.titulo,
            'descripcion': t.descripcion,
            'estado': t.estado,
            'fecha': t.fecha_creacion,
            'autor': t.creador.nombre_completo,
            'comentario_cierre': t.comentario_cierre # <--- AGREGAR ESTO
        })
    return jsonify(lista_tickets)

@app.route('/api/tickets', methods=['POST']) # <--- CAMBIO AQUÍ
def create_ticket():
    data = request.json
    now = datetime.now()
    fecha_str = f"{now.year}-{now.month}-{now.day}"
    
    user_id = data.get('usuario_id', 1) 

    nuevo_ticket = Ticket(
        titulo=data['titulo'],
        descripcion=data['descripcion'],
        estado='Abierto',
        fecha_creacion=fecha_str,
        usuario_id=user_id
    )
    
    db.session.add(nuevo_ticket)
    db.session.commit()
    
    return jsonify({'mensaje': 'Ticket creado exitosamente'}), 201

# --- EN LA RUTA CERRAR (Ahora acepta POST o PUT con body) ---
@app.route('/api/tickets/<int:ticket_id>/cerrar', methods=['PUT'])
def close_ticket(ticket_id):
    ticket = Ticket.query.get(ticket_id)
    data = request.json # Recibimos el JSON con el comentario
    
    if ticket:
        ticket.estado = 'Cerrado'
        # Guardamos el comentario que viene de Flutter
        ticket.comentario_cierre = data.get('comentario', 'Sin comentarios') 
        db.session.commit()
        return jsonify({'mensaje': 'Ticket cerrado'}), 200
    return jsonify({'mensaje': 'Ticket no encontrado'}), 404

if __name__ == '__main__':
    crear_datos_iniciales()
    # Host 0.0.0.0 es vital para que te escuche desde afuera (emulador)
    app.run(debug=True, host='0.0.0.0', port=5000)