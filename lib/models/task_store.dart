// lib/models/task_store.dart
//
// Estado global de tareas. Todas las pantallas leen y escriben aquí.
// Cuando cambia algo, notifica a todos los listeners → se rebuildan solos.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';

class TaskStore extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);
  int get pendingCount => _tasks.where((t) => t.status == 'pending').length;

  // ─── Cargar desde SharedPreferences ──────────────────────────────────
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('academicTasks');
    if (stored != null) {
      _tasks = (jsonDecode(stored) as List).map((e) => Task.fromJson(e)).toList();
    } else {
      _tasks = List.from(kInitialTasks);
      await _persist();
    }
    notifyListeners();
  }

  // ─── Añadir tarea ─────────────────────────────────────────────────────
  Future<void> add(Task task) async {
    _tasks.add(task);
    await _persist();
    notifyListeners();
  }

  // ─── Actualizar tarea ─────────────────────────────────────────────────
  Future<void> update(Task updated) async {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _tasks[idx] = updated;
      await _persist();
      notifyListeners();
    }
  }

  // ─── Eliminar tarea ───────────────────────────────────────────────────
  Future<void> delete(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _persist();
    notifyListeners();
  }

  // ─── Toggle completada/pendiente ──────────────────────────────────────
  Future<void> toggle(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final t = _tasks[idx];
      _tasks[idx] = t.copyWith(status: t.isCompleted ? 'pending' : 'completed');
      await _persist();
      notifyListeners();
    }
  }

  // ─── Buscar por id ────────────────────────────────────────────────────
  Task? find(String id) => _tasks.where((t) => t.id == id).firstOrNull;

  // ─── Guardar en SharedPreferences ─────────────────────────────────────
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('academicTasks', jsonEncode(_tasks.map((t) => t.toJson()).toList()));
  }
}

// ─── InheritedNotifier para acceder al store desde cualquier widget ───────────
class TaskStoreScope extends InheritedNotifier<TaskStore> {
  const TaskStoreScope({
    super.key,
    required TaskStore store,
    required super.child,
  }) : super(notifier: store);

  static TaskStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TaskStoreScope>();
    assert(scope != null, 'TaskStoreScope no encontrado');
    return scope!.notifier!;
  }

  // Sin suscripción (para writes)
  static TaskStore read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<TaskStoreScope>();
    assert(scope != null, 'TaskStoreScope no encontrado');
    return scope!.notifier!;
  }
}
