# 🎫 ServiceDesk Lite - Sistema de Gestión de Tickets

Aplicación móvil desarrollada en **Flutter** que interactúa con una API RESTful construida en **Flask** (Python) para la gestión de tickets de soporte técnico. El proyecto permite a los usuarios autenticarse, crear tickets, visualizar su estado y cerrarlos con comentarios de resolución.

## 🚀 Características Principales

* **Autenticación de Usuarios:** Login seguro validado contra base de datos.
* **Gestión de Sesión:** Persistencia del ID de usuario para asignar la autoría de los tickets.
* **Listado de Tickets:** Visualización de tickets pendientes y cerrados con indicadores de estado por color.
* **Creación de Tickets:** Formulario para registrar nuevos incidentes en la base de datos.
* **Cierre y Resolución:** Flujo para cerrar tickets agregando un comentario de solución (Actualización en tiempo real).
* **Persistencia de Datos:** Uso de SQLite mediante SQLAlchemy.

## 🛠️ Tecnologías Utilizadas

### Backend
* **Python 3.x**
* **Flask** (Framework web)
* **Flask-SQLAlchemy** (ORM para base de datos)
* **Flask-CORS** (Manejo de orígenes cruzados)
* **SQLite** (Base de datos relacional)

### Frontend (Móvil)
* **Flutter** (Dart)
* **Material Design 3**
* **Http** (Consumo de API REST)

---

## 📂 Estructura del Proyecto

El repositorio está organizado como un monorepo:

```text
/sumativa4
│
├── /backend            # Código fuente de la API (Flask)
│   ├── app.py          # Punto de entrada y modelos
│   ├── gestion_tickets.db # Base de datos (se genera automáticamente)
│   └── venv/           # Entorno virtual (no incluido en repo)
│
└── /mobile_app         # Código fuente de la App (Flutter)
    ├── lib/
    │   ├── data/       # Modelos de datos
    │   ├── screens/    # Pantallas (UI)
    │   └── services/   # Lógica de conexión HTTP
    └── pubspec.yaml    # Dependencias de Dart

```


## ⚙️ Instrucciones de Instalación y Ejecución
### Sigue estos pasos para levantar el proyecto en tu entorno local.

1. Configuración del Backend (Servidor)

* **Navega a la carpeta del backend:**

``` Bash
cd backend
```

* **Crea y activa un entorno virtual (Opcional pero recomendado):**

``` Bash
# Windows
python -m venv venv
.\venv\Scripts\activate

# Mac/Linux
python3 -m venv venv
source venv/bin/activate

```

* **Instala las dependencias:**

``` Bash
pip install flask flask-sqlalchemy flask-cors
```

* **Ejecuta el servidor:**

``` Bash
python app.py
```

* **El servidor correrá en http://0.0.0.0:5000. Al iniciar por primera vez, creará automáticamente el archivo gestion_tickets.db y poblará usuarios de prueba.**


2. Configuración del Frontend (App Móvil)
* **Abre una nueva terminal y navega a la carpeta de la app:**

``` Bash
cd mobile_app
```
