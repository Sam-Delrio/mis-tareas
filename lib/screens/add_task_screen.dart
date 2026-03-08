import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/task_store.dart';
import '../theme/color_theme.dart';
import 'dart:ui';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime?  _date;
  TimeOfDay? _time;
  late AppColorPalette _pal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pal = AppThemeScope.of(context).palette;
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
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name, subject: '',
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      dueDate: formatted, reminderTime: reminder, status: 'pending',
    );
    // Escribe en el store → notifica a HomeScreen y CalendarScreen al instante
    await TaskStoreScope.read(context).add(task);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime.now(), lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: _pal.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context, initialTime: TimeOfDay.now(),
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
              _lbl(Icons.auto_awesome, _pal.light, 'Nombre de la Tarea *'),
              const SizedBox(height: 10),
              _field(_nameCtrl, 'ej., Completar Tarea de Física'),
              const SizedBox(height: 24),
              _lbl(Icons.notes_rounded, _pal.secondary, 'Descripción'),
              const SizedBox(height: 10),
              _field(_descCtrl, 'Agrega detalles, notas o instrucciones...', lines: 4),
              const SizedBox(height: 24),
              _lbl(Icons.calendar_today, _pal.light, 'Fecha de Entrega *'),
              const SizedBox(height: 10),
              _dateTile(),
              const SizedBox(height: 24),
              _lbl(Icons.access_time, _pal.secondary, 'Hora de Recordatorio'),
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
              child: const Text('Nueva Tarea', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white))),
            Text('Agrega los detalles', style: TextStyle(fontSize: 12, color: _pal.primary.withOpacity(0.6))),
          ])),
          Icon(Icons.auto_awesome, color: _pal.secondary, size: 24),
        ]),
      )),
    ),
  )).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0);

  Widget _lbl(IconData icon, Color color, String text) => Row(children: [
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
      Icon(Icons.auto_awesome, color: Colors.white, size: 18), SizedBox(width: 8),
      Text('Guardar Tarea', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
    ]),
  ));
}
