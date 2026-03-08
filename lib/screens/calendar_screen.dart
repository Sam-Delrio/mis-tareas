import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../models/task_store.dart';
import '../theme/color_theme.dart';
import '../widgets/bottom_nav.dart';
import 'task_detail_screen.dart';
import 'settings_screen.dart';
import 'dart:ui';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused  = DateTime.now();
  DateTime _selected = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;
  late AppColorPalette _pal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pal = AppThemeScope.of(context).palette;
  }

  DateTime? _parseDate(String s) {
    try { return DateFormat('d MMM, yyyy', 'es_ES').parse(s); } catch (_) {}
    try { return DateFormat('d MMM yyyy',  'es_ES').parse(s); } catch (_) {}
    return null;
  }

  List<Task> _forDay(List<Task> all, DateTime d) => all.where((t) {
    final date = _parseDate(t.dueDate);
    return date != null && isSameDay(date, d);
  }).toList();

  static const Map<String, Color> _colors = {
    'Matemáticas': Color(0xFF4CAF50), 'Física': Color(0xFF2196F3),
    'Química': Color(0xFFFF9800),     'Biología': Color(0xFF8BC34A),
    'Literatura': Color(0xFF9C27B0),  'Historia': Color(0xFFFF5722),
    'Informática': Color(0xFF00BCD4), 'Ingeniería': Color(0xFF3F51B5),
  };
  Color _color(Task t) => _colors[t.subject] ?? const Color(0xFF607D8B);

  @override
  Widget build(BuildContext context) {
    _pal = AppThemeScope.of(context).palette;
    // Lee del store reactivo — no necesita _load() ni SharedPreferences
    final tasks    = TaskStoreScope.of(context).tasks;
    final dayTasks = _forDay(tasks, _selected);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        Column(children: [
          _header(),
          Expanded(child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Container(
              color: Colors.white.withOpacity(0.7),
              child: _calendar(tasks),
            )),
            SliverToBoxAdapter(child: _dayHeader(dayTasks)),
            if (dayTasks.isEmpty)
              SliverToBoxAdapter(child: _empty())
            else
              SliverList(delegate: SliverChildBuilderDelegate(
                (_, i) => _taskItem(dayTasks[i], i),
                childCount: dayTasks.length,
              )),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ])),
        ]),
        BottomNav(
          currentIndex: 1,
          onTabSelected: (i) {
            if (i == 1) return;
            if (i == 0) { Navigator.pop(context); return; }
            Navigator.pop(context);
            Future.microtask(() {
              if (context.mounted) Navigator.push(context, PageRouteBuilder(
                pageBuilder: (_, __, ___) => const SettingsScreen(),
                transitionDuration: const Duration(milliseconds: 180),
                transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
              ));
            });
          },
        ),
      ]),
    );
  }

  Widget _header() => ClipRect(child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
    child: Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.5)))),
      child: SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
        child: Row(children: [
          Expanded(child: RichText(text: TextSpan(children: [
            TextSpan(text: DateFormat('MMMM ', 'es_ES').format(_focused),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E))),
            TextSpan(text: DateFormat('yyyy').format(_focused),
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: _pal.primary)),
          ]))),
          _ViewToggle(current: _format, pal: _pal, onChanged: (f) => setState(() => _format = f)),
        ]),
      )),
    ),
  ));

  Widget _calendar(List<Task> allTasks) => TableCalendar(
    locale: 'es_ES',
    firstDay: DateTime(2020), lastDay: DateTime(2030),
    focusedDay: _focused,
    selectedDayPredicate: (d) => isSameDay(_selected, d),
    calendarFormat: _format,
    startingDayOfWeek: StartingDayOfWeek.sunday,
    availableCalendarFormats: const {
      CalendarFormat.month: 'Mes',
      CalendarFormat.twoWeeks: '2 Sem',
      CalendarFormat.week: 'Semana',
    },
    onDaySelected: (sel, foc) => setState(() { _selected = sel; _focused = foc; }),
    onFormatChanged: (f) => setState(() => _format = f),
    onPageChanged: (foc) => setState(() => _focused = foc),
    eventLoader: (d) => _forDay(allTasks, d),
    calendarStyle: CalendarStyle(
      todayDecoration: BoxDecoration(gradient: _pal.titleGradient, shape: BoxShape.circle),
      todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      selectedDecoration: BoxDecoration(color: _pal.primary, shape: BoxShape.circle),
      selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      defaultTextStyle: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 14),
      weekendTextStyle: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 14),
      outsideTextStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
      markerDecoration: BoxDecoration(color: _pal.secondary, shape: BoxShape.circle),
      markerSize: 5, markersMaxCount: 3,
    ),
    daysOfWeekStyle: DaysOfWeekStyle(
      weekdayStyle: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
      weekendStyle: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
    ),
    headerVisible: false,
  );

  Widget _dayHeader(List<Task> tasks) {
    final isToday = isSameDay(_selected, DateTime.now());
    return Container(
      color: const Color(0xFF1C1C1E),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        RichText(text: TextSpan(children: [
          if (isToday) TextSpan(text: 'HOY  ',
            style: TextStyle(color: _pal.light, fontWeight: FontWeight.w700, fontSize: 14)),
          TextSpan(text: DateFormat('d/MM/yy').format(_selected),
            style: TextStyle(color: _pal.light, fontSize: 14)),
        ])),
        const Spacer(),
        Text('${tasks.length} tarea${tasks.length != 1 ? 's' : ''}',
          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ]),
    );
  }

  Widget _empty() => Container(
    color: const Color(0xFF1C1C1E),
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(children: [
      Icon(Icons.event_available, color: Colors.grey[700], size: 40),
      const SizedBox(height: 12),
      Text('Sin tareas este día', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
    ]),
  );

  Widget _taskItem(Task task, int index) {
    final color = _color(task);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => TaskDetailScreen(taskId: task.id),
      )),
      child: Container(
        color: const Color(0xFF1C1C1E),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 5), child: Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: task.isCompleted ? color.withOpacity(0.4) : color,
              shape: BoxShape.circle,
            ),
          )),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (task.reminderTime != null)
              Text(task.reminderTime!,
                style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(task.name, style: TextStyle(
              color: task.isCompleted ? Colors.grey[600] : Colors.white,
              fontSize: 15, fontWeight: FontWeight.w500,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            )),
            if (task.description != null && task.description!.isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 2),
                child: Text(task.description!, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12))),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: task.isCompleted ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(task.isCompleted ? '✓ Lista' : 'Pendiente',
              style: TextStyle(
                color: task.isCompleted ? Colors.green[400] : Colors.orange[400],
                fontSize: 11, fontWeight: FontWeight.w600,
              )),
          ),
        ]),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 80), duration: 300.ms)
     .slideX(begin: 0.1, end: 0);
  }
}

class _ViewToggle extends StatelessWidget {
  final CalendarFormat current;
  final AppColorPalette pal;
  final ValueChanged<CalendarFormat> onChanged;
  const _ViewToggle({required this.current, required this.pal, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
    child: Row(children: [_btn('M', CalendarFormat.month), _btn('S', CalendarFormat.week)]),
  );

  Widget _btn(String label, CalendarFormat fmt) {
    final active = current == fmt;
    return GestureDetector(
      onTap: () => onChanged(fmt),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : null,
        ),
        child: Text(label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: active ? pal.primary : Colors.grey[600],
        )),
      ),
    );
  }
}
