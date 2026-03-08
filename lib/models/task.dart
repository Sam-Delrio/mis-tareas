// lib/models/task.dart

class Task {
  final String id;
  final String name;
  final String subject; // Se mantiene para compatibilidad con calendario/cards
  final String? description; // NUEVO: descripción libre del usuario
  final String dueDate;
  final String? reminderTime;
  final String status;

  Task({
    required this.id,
    required this.name,
    required this.subject,
    this.description,
    required this.dueDate,
    this.reminderTime,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      subject: json['subject'] ?? '',
      description: json['description'],
      dueDate: json['dueDate'],
      reminderTime: json['reminderTime'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'description': description,
      'dueDate': dueDate,
      'reminderTime': reminderTime,
      'status': status,
    };
  }

  Task copyWith({
    String? id,
    String? name,
    String? subject,
    String? description,
    String? dueDate,
    String? reminderTime,
    String? status,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      status: status ?? this.status,
    );
  }

  bool get isCompleted => status == 'completed';
}

// Una sola tarea de ejemplo para el primer inicio
final List<Task> kInitialTasks = [
  Task(
    id: '1',
    name: '¡Bienvenido a Task Manager!',
    subject: '',
    description:
        'Esta es tu primera tarea de ejemplo. Puedes editarla o eliminarla y empezar a agregar las tuyas.',
    dueDate: '31 dic, 2026',
    reminderTime: '09:00 AM',
    status: 'pending',
  ),
];
