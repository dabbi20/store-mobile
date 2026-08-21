#  EcoHome Store

EcoHome Store es una aplicación full-stack desarrollada como proyecto académico que integra un backend REST, una aplicación web en React y una aplicación multiplataforma en Flutter.

El sistema permite autenticación mediante JWT, gestión de productos, perfiles de usuario, control de permisos, estadísticas y comunicación en tiempo real mediante Socket.IO.

---

##  Descripción

EcoHome Store está compuesto por tres aplicaciones principales:

- Backend desarrollado con Node.js y Express.
- Frontend web desarrollado con React.
- Cliente multiplataforma desarrollado con Flutter.

Las aplicaciones React y Flutter consumen el mismo backend y comparten la información almacenada en PostgreSQL.

Además, ambas aplicaciones pueden comunicarse en tiempo real mediante Socket.IO.

---

##  Arquitectura

```text
                    ┌──────────────────────┐
                    │      PostgreSQL      │
                    │                      │
                    │ Users                │
                    │ Products             │
                    │ Messages             │
                    └──────────┬───────────┘
                               │
                               │
                    ┌──────────▼───────────┐
                    │    Node.js/Express   │
                    │       Backend        │
                    │                      │
                    │ REST API             │
                    │ JWT                  │
                    │ Socket.IO            │
                    │ Roles / permisos     │
                    └───────┬───────┬──────┘
                            │       │
                    HTTP    │       │ Socket.IO
                            │       │
              ┌─────────────▼─┐   ┌─▼──────────────┐
              │     React     │   │     Flutter    │
              │   Frontend    │   │     Client     │
              │               │   │                │
              │ Web           │   │ Web / Mobile   │
              └───────────────┘   └────────────────┘
```

---

##  Tecnologías utilizadas

### Backend

- Node.js
- Express
- PostgreSQL
- JWT
- Socket.IO
- bcrypt
- dotenv
- CORS

### Frontend Web

- React
- JavaScript
- React Router
- Fetch / API REST
- Socket.IO Client

### Flutter

- Flutter
- Dart
- Material Design
- SharedPreferences
- HTTP
- Socket.IO Client

### Base de datos

- PostgreSQL

---

#  Autenticación

El sistema utiliza autenticación mediante JSON Web Token (JWT).

Después de iniciar sesión correctamente, el backend genera un token que contiene información del usuario autenticado.

El token permite identificar al usuario y proteger las operaciones que requieren autenticación.

En Flutter el token se almacena utilizando `SharedPreferences`.

El flujo general es:

```text
Usuario
   │
   ▼
Login
   │
   ▼
POST /login
   │
   ▼
Backend valida credenciales
   │
   ▼
Generación JWT
   │
   ▼
Token almacenado
   │
   ▼
Peticiones autenticadas
```

La aplicación también valida la sesión existente al iniciarse.

---

#  Roles y permisos

El sistema maneja diferentes roles de usuario.

Entre ellos:

```text
admin
cliente
```

Los usuarios administradores pueden crear productos.

Las operaciones de modificación y eliminación están protegidas tanto desde la interfaz como desde el backend.

Un administrador únicamente puede modificar o eliminar productos que le pertenecen según las reglas implementadas en el sistema.

---

#  Gestión de productos

El sistema implementa operaciones CRUD sobre productos.

Entre las funcionalidades disponibles se encuentran:

- Consultar productos.
- Consultar información de un producto.
- Crear productos.
- Editar productos.
- Eliminar productos.
- Identificar al creador de cada producto.
- Mostrar estadísticas de productos creados por usuario.

Ejemplo de producto:

```json
{
  "id": 19,
  "name": "oreo",
  "price": "50.00",
  "created_at": "2026-08-21T19:04:27.056Z",
  "updated_at": "2026-08-21T19:04:27.056Z",
  "created_by": 1,
  "created_by_username": "admin"
}
```

---

#  Trazabilidad de productos

Cada producto registra qué usuario lo creó.

La relación se realiza mediante:

```text
products.created_by
        │
        ▼
users.id
```

Esto permite conocer el propietario o creador de cada producto.

El backend obtiene el usuario autenticado directamente desde el JWT, evitando depender de un identificador enviado manualmente por el cliente.

Ejemplo:

```text
Producto: Plato biodegradable
Precio: $12.50
Creado por: admin
```

---

#  Contador dinámico de productos

El sistema muestra la cantidad de productos creados por el usuario autenticado.

Ejemplo:

```text
admin2 (2)
```

Después de crear un nuevo producto:

```text
admin2 (3)
```

El contador se actualiza dinámicamente sin necesidad de cerrar sesión.

Esta funcionalidad está implementada tanto en React como en Flutter.

También se dispone de una sección de estadísticas dentro del perfil del usuario.

---

#  Chat en tiempo real

EcoHome Store incorpora un chat interno utilizando Socket.IO.

Los usuarios autenticados pueden enviar y recibir mensajes en tiempo real.

El backend utiliza eventos como:

```text
message-history
new-message
message-error
```

Cuando un usuario se conecta, el servidor recupera los últimos mensajes almacenados.

```text
Flutter / React
      │
      ▼
Socket.IO Client
      │
      ▼
Node.js + Socket.IO
      │
      ├──────────────► PostgreSQL
      │
      ▼
io.emit("new-message")
      │
      ├──────────────► React
      │
      └──────────────► Flutter
```

Esto permite que un mensaje enviado desde React aparezca inmediatamente en Flutter y viceversa.

---

# 💾 Persistencia del chat

Los mensajes no existen únicamente durante la conexión WebSocket.

Cada mensaje enviado se almacena en PostgreSQL.

Al conectarse un usuario, el backend recupera los últimos mensajes mediante el evento:

```text
message-history
```

Por lo tanto, el historial permanece disponible incluso después de desconectarse y volver a ingresar.

---

#  Aplicación Flutter

El cliente Flutter implementa:

- Inicio de sesión.
- Persistencia de sesión.
- Validación del JWT.
- Catálogo de productos.
- Creación de productos.
- Edición de productos.
- Eliminación de productos.
- Detalle de producto.
- Perfil de usuario.
- Estadísticas.
- Control de permisos.
- Chat en tiempo real.
- Historial de mensajes.
- Actualización dinámica del contador de productos.
- Cierre de sesión.

La interfaz utiliza Material Design.

---

# 🌐 Aplicación React

La aplicación React permite:

- Inicio de sesión.
- Visualización del catálogo.
- Creación de productos.
- Edición y eliminación según permisos.
- Visualización del creador de cada producto.
- Perfil del usuario.
- Edición del perfil.
- Cambio de contraseña.
- Estadísticas.
- Contador dinámico de productos.
- Chat en tiempo real.
- Cierre de sesión.

---

# 🔄 Comunicación React ↔ Flutter

React y Flutter utilizan el mismo backend.

Esto permite comprobar la interoperabilidad entre ambos clientes.

Por ejemplo:

```text
React
   │
   │ new-message
   ▼
Node.js + Socket.IO
   │
   ▼
Flutter
```

También funciona en sentido contrario:

```text
Flutter
   │
   │ new-message
   ▼
Node.js + Socket.IO
   │
   ▼
React
```

Los mensajes se reciben sin necesidad de actualizar manualmente la página.

---

#  Perfil de usuario

El sistema permite consultar información del usuario autenticado:

- ID.
- Username.
- Email.
- Rol.
- Fecha de registro.
- Cantidad de productos creados.

También permite:

- Actualizar username.
- Actualizar email.
- Cambiar contraseña.

---

#  Base de datos

La aplicación utiliza PostgreSQL.

Entre las tablas principales se encuentran:

```text
users
products
messages
```

Relaciones principales:

```text
users
 ├── products
 │      └── created_by
 │
 └── messages
        └── user_id
```

---

#  API REST

Algunos de los endpoints utilizados por el sistema son:

## Productos

```http
GET /products
GET /products/:id
POST /products
PUT /products/:id
PATCH /products/:id
DELETE /products/:id
```

Las operaciones de creación, actualización y eliminación están protegidas mediante JWT y autorización por rol.

## Usuario

```http
GET /users/me
GET /users/me/stats
PATCH /users/me
PATCH /users/me/password
```

Estos endpoints permiten consultar el perfil, obtener estadísticas y actualizar información del usuario autenticado.

---

#  Socket.IO

La conexión Socket.IO también requiere autenticación.

El cliente envía el JWT durante la conexión.

Ejemplo conceptual:

```javascript
const socket = io("http://localhost:3000", {
  auth: {
    token
  }
});
```

El servidor valida el token antes de permitir la conexión.

---

# ▶ Ejecutar el proyecto

## 1. Backend

Entrar al proyecto:

```bash
cd store-backend
```

Instalar dependencias:

```bash
npm install
```

Configurar las variables de entorno en:

```text
.env
```

Ejecutar:

```bash
node src/app.js
```

El servidor se ejecuta localmente en:

```text
http://localhost:3000
```

---

## 2. React

Entrar al frontend:

```bash
cd store-frontend
```

Instalar dependencias:

```bash
npm install
```

Ejecutar:

```bash
npm run dev
```

La aplicación estará disponible normalmente en:

```text
http://localhost:5173
```

---

## 3. Flutter

Entrar al proyecto:

```bash
cd store_app
```

Instalar dependencias:

```bash
flutter pub get
```

Verificar el proyecto:

```bash
flutter analyze
```

Ejecutar en Chrome:

```bash
flutter run -d chrome --web-port=5000
```

La aplicación estará disponible en:

```text
http://localhost:5000
```

---

#  Pruebas realizadas

Durante el desarrollo se comprobaron los siguientes escenarios:

- Inicio de sesión correcto.
- Persistencia del JWT.
- Validación de sesión.
- Consulta del catálogo.
- Creación de productos.
- Actualización de productos.
- Eliminación de productos.
- Restricción de operaciones según usuario.
- Visualización del creador.
- Estadísticas por usuario.
- Actualización dinámica del contador.
- Comunicación React → Flutter.
- Comunicación Flutter → React.
- Persistencia del historial del chat.
- Edición del perfil.
- Cambio de contraseña.

Una de las pruebas realizadas con el contador fue:

```text
admin2 (1)
      ↓
Crear producto
      ↓
admin2 (2)
```

Posteriormente, desde Flutter:

```text
admin2 (2)
      ↓
Crear producto
      ↓
admin2 (3)
```

Esto demuestra que ambos clientes trabajan sobre la misma información proporcionada por el backend.

---

#  Estructura general

```text
EcoHome Store
│
├── store-backend
│   └── Node.js + Express
│       ├── controllers
│       ├── middleware
│       ├── models
│       ├── routes
│       └── services
│
├── store-frontend
│   └── React
│
└── store_app
    └── Flutter
        └── lib
            ├── core
            │   ├── network
            │   └── storage
            ├── models
            ├── screens
            └── services
```

---

#  Seguridad

Entre las medidas implementadas se encuentran:

- Autenticación mediante JWT.
- Validación del token en rutas protegidas.
- Autenticación de conexiones Socket.IO.
- Autorización basada en roles.
- Validación de propiedad de productos.
- Contraseñas gestionadas de forma segura desde el backend.
- Variables sensibles almacenadas mediante variables de entorno.

> El archivo `.env` no debe publicarse en el repositorio.

---

#  Estado del proyecto

Las funcionalidades principales se encuentran implementadas y operativas:

```text
Backend REST              ✅
PostgreSQL                 ✅
Autenticación JWT          ✅
Roles y permisos           ✅
CRUD de productos          ✅
Trazabilidad de productos  ✅
Perfil de usuario          ✅
Estadísticas               ✅
Contador dinámico          ✅
Frontend React             ✅
Cliente Flutter            ✅
Socket.IO                  ✅
Chat en tiempo real        ✅
Historial de mensajes      ✅
React ↔ Flutter            ✅
```

---

## 👨‍💻 Autor

Proyecto desarrollado con fines académicos.

**David Carrasco**

---

## 📄 Licencia

Proyecto académico y educativo.