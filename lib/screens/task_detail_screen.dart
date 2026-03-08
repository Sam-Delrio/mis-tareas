import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task.dart';
import '../models/task_store.dart';
import '../theme/color_theme.dart';
import '../theme/app_theme.dart';
import 'edit_task_screen.dart';
import 'dart:ui';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});
  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late AppColorPalette _pal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pal = AppThemeScope.of(context).palette;
  }

  @override
  Widget build(BuildContext context) {
    _pal = AppThemeScope.of(context).palette;
    // Lee del store reactivo — se actualiza solo cuando cambia la tarea
    final store = TaskStoreScope.of(context);
    final task  = store.find(widget.taskId);

    if (task == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: GlassBlurContainer(
          borderRadius: BorderRadius.circular(28), padding: const EdgeInsets.all(32),
          child: const Text('Tarea no encontrada', style: TextStyle(color: Color(0xFF4B5563))),
        ).animate().fadeIn()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        _header(task),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(children: [
            _infoCard(task).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 24),
            _actions(task, store),
          ]),
        )),
      ]),
    );
  }

  Widget _header(Task task) => ClipRect(child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
    child: Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.5)))),
      child: SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Row(children: [
          GestureDetector(onTap: () => Navigator.pop(context),
            child: Container(width: 40, height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.25), border: Border.all(color: Colors.white.withOpacity(0.2))),
              child: Icon(Icons.arrow_back, color: _pal.primary, size: 20))),
          const SizedBox(width: 16),
          Expanded(child: ShaderMask(
            shaderCallback: (b) => _pal.titleGradient.createShader(b),
            child: const Text('Detalles', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)))),
          Icon(task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: task.isCompleted ? const Color(0xFF10B981) : _pal.light, size: 24),
        ]),
      )),
    ),
  )).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0);

  Widget _infoCard(Task task) => GlassBlurContainer(
    borderRadius: BorderRadius.circular(28), addShadow: true,
    child: Stack(children: [
      Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(task.name, style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600,
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? Colors.grey.withOpacity(0.6) : const Color(0xFF374151),
        )),
        const SizedBox(height: 20),
        if (task.description != null && task.description!.isNotEmpty) ...[
          _row([_pal.light, _pal.secondary], Icons.notes_rounded, 'Descripción', task.description!, 200),
          const SizedBox(height: 16),
        ],
        _row([_pal.secondary, _pal.lighter], Icons.calendar_today, 'Fecha de Entrega', task.dueDate, 300),
        if (task.reminderTime != null) ...[
          const SizedBox(height: 16),
          _row([_pal.lighter, const Color(0xFF34D399)], Icons.access_time, 'Recordatorio', task.reminderTime!, 400),
        ],
        const SizedBox(height: 16),
        _statusBadge(task),
      ])),
      Positioned(top: 0, left: 0, right: 0, child: Container(
        height: 3,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
          gradient: _pal.buttonGradient,
        ),
      )),
    ]),
  );

  Widget _row(List<Color> colors, IconData icon, String label, String value, int delay) =>
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 48, height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
          boxShadow: [BoxShadow(color: colors[0].withOpacity(0.4), blurRadius: 10)],
        ),
        child: Icon(icon, color: Colors.white, size: 20)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151), height: 1.4)),
      ])),
    ]).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: -0.2, end: 0);

  Widget _statusBadge(Task task) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: task.isCompleted ? AppTheme.completedGradient : AppTheme.pendingGradient,
      boxShadow: [BoxShadow(
        color: (task.isCompleted ? const Color(0xFF34D399) : const Color(0xFFFBBF24)).withOpacity(0.4),
        blurRadius: 10,
      )],
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(task.isCompleted ? Icons.check_circle : Icons.circle_outlined, color: Colors.white, size: 16),
      const SizedBox(width: 6),
      Text(task.isCompleted ? 'Completada' : 'Pendiente',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
    ]),
  ).animate().fadeIn(delay: 500.ms);

  Widget _actions(Task task, TaskStore store) => Column(children: [
    // Toggle completada/pendiente
    _primaryBtn(
      gradient: task.isCompleted
          ? const LinearGradient(colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)])
          : _pal.buttonGradient,
      icon: task.isCompleted ? Icons.circle_outlined : Icons.check_circle,
      label: task.isCompleted ? 'Marcar como Pendiente' : 'Marcar como Completada',
      shadow: task.isCompleted ? Colors.grey : _pal.light,
      onTap: () => store.toggle(task.id),  // ← store, no SharedPreferences
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
    const SizedBox(height: 16),

    // Editar
    _glassBtn(Icons.edit, 'Editar', _pal.primary, () =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)))
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
    const SizedBox(height: 16),

    // Eliminar
    _glassBtn(Icons.delete_outline, 'Eliminar', Colors.red.shade400, () async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Eliminar tarea'),
          content: const Text('¿Estás seguro de que quieres eliminar esta tarea?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
          ],
        ),
      );
      if (ok == true && context.mounted) {
        await store.delete(task.id);  // ← store, no SharedPreferences
        if (context.mounted) Navigator.pop(context);
      }
    }).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
  ]);

  Widget _primaryBtn({required LinearGradient gradient, required IconData icon, required String label, required Color shadow, required VoidCallback onTap}) =>
    GestureDetector(onTap: onTap, child: Container(
      width: double.infinity, height: 56,
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: shadow.withOpacity(0.4), blurRadius: 16, spreadRadius: 2)]),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ]),
    ));

  Widget _glassBtn(IconData icon, String label, Color color, VoidCallback onTap) =>
    GestureDetector(onTap: onTap, child: GlassBlurContainer(
      borderRadius: BorderRadius.circular(16),
      child: Container(width: double.infinity, height: 56, alignment: Alignment.center,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 18), const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
        ])),
    ));
}
