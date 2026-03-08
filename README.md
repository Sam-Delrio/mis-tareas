# 📚 Task Manager Académico — Flutter

Conversión del proyecto React/Tailwind a Flutter/Dart.

---

## 🗂️ Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada (equivale a main.tsx + App.tsx)
├── models/
│   └── task.dart                # Modelo de datos Task (equivale a interface Task en TS)
├── theme/
│   └── app_theme.dart           # Colores, gradientes y widgets glass (equivale a theme.css)
├── widgets/
│   ├── task_card.dart           # Tarjeta de tarea (equivale a TaskCard.tsx)
│   └── bottom_nav.dart          # Barra de navegación (equivale a BottomNav.tsx)
└── screens/
    ├── home_screen.dart         # Pantalla principal (equivale a Home.tsx)
    ├── add_task_screen.dart     # Agregar tarea (equivale a AddTask.tsx)
    └── task_detail_screen.dart  # Detalle de tarea (equivale a TaskDetail.tsx)
```

---

## 🚀 Cómo correr el proyecto

### 1. Instalar Flutter
Si aún no tienes Flutter instalado, ve a: https://docs.flutter.dev/get-started/install

### 2. Verificar que todo esté bien
```bash
flutter doctor
```
Asegúrate de que no haya errores en rojo.

### 3. Instalar dependencias
Dentro de la carpeta del proyecto:
```bash
flutter pub get
```

### 4. Correr la app
```bash
# En un emulador o dispositivo conectado:
flutter run

# Solo en Chrome (web):
flutter run -d chrome

# Ver dispositivos disponibles:
flutter devices
```

---

## 📦 Dependencias utilizadas

| Paquete | Versión | Equivalente en React |
|---|---|---|
| `shared_preferences` | ^2.2.2 | `localStorage` |
| `flutter_animate` | ^4.5.0 | `motion/react` (animaciones) |
| `intl` | ^0.19.0 | `Date.toLocaleDateString()` |

---

## 🎨 Equivalencias de diseño

| Tailwind/CSS | Flutter |
|---|---|
| `glass` (backdrop-filter blur) | `BackdropFilter` + `ImageFilter.blur()` |
| `bg-gradient-to-r from-blue-600 to-cyan-500` | `LinearGradient(colors: [...])` |
| `bg-clip-text` (texto gradiente) | `ShaderMask` con `LinearGradient` |
| `rounded-3xl` | `BorderRadius.circular(24)` |
| `shadow-lg shadow-blue-200/30` | `BoxShadow(color: ..., blurRadius: ...)` |
| `motion initial={{ opacity: 0, y: 20 }}` | `.animate().fadeIn().slideY(...)` |
| `localStorage` | `SharedPreferences` |
| `useNavigate()` | `Navigator.push()` / `Navigator.pop()` |
| `useState()` | `setState()` en StatefulWidget |
| `useEffect()` | `initState()` |

---

## 📱 Pantallas

1. **HomeScreen** — Lista todas las tareas, botón FAB para agregar, BottomNav
2. **AddTaskScreen** — Formulario para crear nueva tarea (nombre, materia, fecha, hora)
3. **TaskDetailScreen** — Ver detalles, marcar completa/pendiente, eliminar

---

## 💡 Conceptos clave para nuevos en Flutter

- **Widget** = Componente de React. Todo en Flutter es un widget.
- **StatefulWidget** = Componente con `useState`. Puede cambiar su estado.
- **StatelessWidget** = Componente sin estado (solo recibe props).
- **`build()`** = Equivalente al `return (...)` en un componente React.
- **`setState()`** = Equivalente a `setMiEstado(nuevoValor)` en React.
- **`Navigator.push()`** = Equivalente a `navigate('/ruta')` de React Router.
- **`Navigator.pop()`** = Equivalente a `navigate(-1)` o `navigate('/')`.
