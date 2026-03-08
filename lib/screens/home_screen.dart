import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task_store.dart';
import '../theme/color_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/bottom_nav.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import 'dart:ui';

Route _fade(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionDuration: const Duration(milliseconds: 180),
  transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  void _onNavTap(int i) {
    if (i == _navIndex) return;
    if (i == 0) { setState(() => _navIndex = 0); return; }
    setState(() => _navIndex = i);
    final page = i == 1 ? const CalendarScreen() : const SettingsScreen();
    Navigator.push(context, _fade(page)).then((_) => setState(() => _navIndex = 0));
  }

  @override
  Widget build(BuildContext context) {
    // dependOnInherited → se rebuilda automáticamente cuando cambian las tareas
    final store   = TaskStoreScope.of(context);
    final palette = AppThemeScope.of(context).palette;
    final tasks   = store.tasks;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        Column(children: [
          _header(palette, store.pendingCount),
          Expanded(child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            children: tasks.isEmpty
                ? [_empty(palette)]
                : tasks.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TaskCard(
                      task: t,
                      onTap: () => Navigator.push(context, _fade(TaskDetailScreen(taskId: t.id))),
                    ),
                  )).toList(),
          )),
        ]),
        Positioned(bottom: 100, right: 24, child: _fab(palette)),
        BottomNav(currentIndex: _navIndex, onTabSelected: _onNavTap),
      ]),
    );
  }

  Widget _header(AppColorPalette p, int pending) => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.5))),
          boxShadow: [BoxShadow(color: p.light.withOpacity(0.2), blurRadius: 10)],
        ),
        child: SafeArea(bottom: false, child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ShaderMask(
              shaderCallback: (b) => p.titleGradient.createShader(b),
              child: const Text('Mis Tareas',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
            const SizedBox(height: 4),
            Text('$pending pendientes',
                style: TextStyle(fontSize: 13, color: p.primary.withOpacity(0.7))),
          ]),
        )),
      ),
    ),
  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0);

  Widget _empty(AppColorPalette p) => GlassBlurContainer(
    borderRadius: BorderRadius.circular(28), padding: const EdgeInsets.all(48),
    child: Column(children: [
      Container(width: 80, height: 80,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: p.iconGradient),
        child: const Icon(Icons.add, color: Colors.white, size: 36)),
      const SizedBox(height: 16),
      Text('No hay tareas aún', style: TextStyle(color: p.primary.withOpacity(0.8), fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text('¡Agrega tu primera tarea!', style: TextStyle(fontSize: 13, color: p.light.withOpacity(0.6))),
    ]),
  ).animate().fadeIn(duration: 400.ms);

  Widget _fab(AppColorPalette p) => GestureDetector(
    onTap: () => Navigator.push(context, _fade(const AddTaskScreen())),
    child: Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle, gradient: p.iconGradient,
        boxShadow: [BoxShadow(color: p.light.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)],
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    ),
  ).animate().scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms);
}
