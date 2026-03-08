import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/task_store.dart';
import '../theme/color_theme.dart';
import 'dart:ui';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});
  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  DateTime?  _date;
  TimeOfDay? _time;
  late AppColorPalette _pal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pal = AppThemeScope.of(context).palette;
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.task.name);
    _descCtrl = TextEditingController(text: widget.task.description ?? '');
    try { _date = DateFormat('d MMM, yyyy', 'es_ES').parse(widget.task.dueDate); } catch (_) {}
    if (widget.task.reminderTime != null) {
      try {
        final parts = widget.task.reminderTime!.split(' ');
        final tp = parts[0].split(':');
        int h = int.parse(tp[0]);
        final m = int.parse(tp[1]);
        if (parts[1] == 'PM' && h != 12) h += 12;
        if (parts[1] == 'AM' && h == 12) h = 0;
        _time = TimeOfDay(hour: h, minute: m);
      } catch (_) {}
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Por favor completa los campos requeridos'),
        backgroundColor: _pal.primary.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    final formatted = DateFormat('d MMM, yyyy', 'es_ES').format(_date!);
    String? reminder;
    if (_time != null) {
      final h = _time!.hourOfPeriod == 0 ? 12 : _time!.hourOfPeriod;
      final m = _time!.minute.toString().padLeft(2, '0');
      reminder = '$h:$m ${_time!.period == DayPeriod.am ? 'AM' : 'PM'}';
    }
    final updated = widget.task.copyWith(
      name: name,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      dueDate: formatted,
      reminderTime: reminder,
    );
    // Actualiza el store → notifica a todos los listeners al instante
    await TaskStoreScope.read(context).update(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('✓ Tarea actualizada correctamente'),
        backgroundColor: const Color(0xFF10B981).withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020), lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: _pal.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context, initialTime: _time ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: _pal.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    _pal = AppThemeScope.of(context).palette;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        _header(),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: GlassBlurContainer(
            borderRadius: BorderRadius.circular(28), padding: const EdgeInsets.all(24), addShadow: true,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _lbl(_pal.light, Icons.auto_awesome, 'Nombre de la Tarea *'),
              const SizedBox(height: 10),
              _field(_nameCtrl, 'ej., Completar Tarea de Física'),
              const SizedBox(height: 24),
              _lbl(_pal.secondary, Icons.notes_rounded, 'Descripción'),
              const SizedBox(height: 10),
              _field(_descCtrl, 'Agrega detalles, notas o instrucciones...', lines: 4),
              const SizedBox(height: 24),
              _lbl(_pal.light, Icons.calendar_today, 'Fecha de Entrega *'),
              const SizedBox(height: 10),
              _dateTile(),
              const SizedBox(height: 24),
              _lbl(_pal.secondary, Icons.access_time, 'Hora de Recordatorio'),
              const SizedBox(height: 10),
              _timeTile(),
              const SizedBox(height: 32),
              _saveBtn(),
            ]),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
        )),
      ]),
    );
  }

  Widget _header() => ClipRect(child: BackdropFilter(
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
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ShaderMask(shaderCallback: (b) => _pal.titleGradient.createShader(b),
              child: const Text('Editar Tarea', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white))),
            Text('Modifica los detalles', style: TextStyle(fontSize: 12, color: _pal.primary.withOpacity(0.6))),
          ])),
          Icon(Icons.edit_rounded, color: _pal.secondary, size: 24),
        ]),
      )),
    ),
  )).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0);

  Widget _lbl(Color color, IconData icon, String text) => Row(children: [
    Icon(icon, size: 16, color: color), const SizedBox(width: 8),
    Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
  ]);

  Widget _field(TextEditingController c, String hint, {int lines = 1}) => Container(
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.2))),
    child: TextField(controller: c, maxLines: lines,
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 14), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
      style: const TextStyle(color: Color(0xFF374151), fontSize: 14)),
  );

  Widget _dateTile() => GestureDetector(onTap: _pickDate, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.2))),
    child: Row(children: [
      Expanded(child: Text(_date != null ? DateFormat('dd/MM/yyyy').format(_date!) : 'Selecciona una fecha',
        style: TextStyle(color: _date != null ? const Color(0xFF374151) : Colors.grey.withOpacity(0.6), fontSize: 14))),
      Icon(Icons.calendar_today, color: _pal.light, size: 18),
    ]),
  ));

  Widget _timeTile() => GestureDetector(onTap: _pickTime, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.2))),
    child: Row(children: [
      Expanded(child: Text(_time != null ? _time!.format(context) : 'Selecciona una hora',
        style: TextStyle(color: _time != null ? const Color(0xFF374151) : Colors.grey.withOpacity(0.6), fontSize: 14))),
      Icon(Icons.access_time, color: _pal.secondary, size: 18),
    ]),
  ));

  Widget _saveBtn() => GestureDetector(onTap: _save, child: Container(
    width: double.infinity, height: 56,
    decoration: BoxDecoration(gradient: _pal.buttonGradient, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: _pal.light.withOpacity(0.4), blurRadius: 16, spreadRadius: 2)]),
    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.save_rounded, color: Colors.white, size: 18), SizedBox(width: 8),
      Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
    ]),
  ));
}
