// lib/screens/settings_screen.dart
//
// Pantalla de Ajustes:
// - Selector de tema de color (8 paletas)
// - Botón de cerrar sesión → vuelve a LoginScreen

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/color_theme.dart';
import '../widgets/bottom_nav.dart';
import 'login_screen.dart';
import 'calendar_screen.dart';
import 'dart:ui';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppColorPalette _activePalette;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activePalette = AppThemeScope.of(context).palette;
  }

  Future<void> _selectPalette(AppColorPalette palette) async {
    // Actualiza el tema en el notifier → toda la app se rebuilda
    AppThemeScope.of(context).setPalette(palette);
    setState(() => _activePalette = palette);

    // Persistir la selección
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('colorPalette', palette.id);
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Cerrar sesión', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.of(context).palette;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(palette),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                  children: [
                    // ── Sección: Tema de Color ──────────────────────────
                    _sectionTitle('🎨  Tema de Color'),
                    const SizedBox(height: 16),
                    _colorGrid(palette),
                    const SizedBox(height: 32),

                    // ── Sección: Vista previa ───────────────────────────
                    _sectionTitle('👁️  Vista Previa'),
                    const SizedBox(height: 16),
                    _preview(palette),
                    const SizedBox(height: 32),

                    // ── Sección: Cuenta ─────────────────────────────────
                    _sectionTitle('👤  Cuenta'),
                    const SizedBox(height: 16),
                    _logoutButton(palette),
                  ],
                ),
              ),
            ],
          ),
          BottomNav(
            currentIndex: 2,
            onTabSelected: (i) {
              if (i == 2) return; // ya estamos aquí
              if (i == 0) {
                Navigator.pop(context); // volver a Home
              } else if (i == 1) {
                // Ir a Calendario: pop y luego push
                Navigator.pop(context);
                Future.microtask(() {
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const CalendarScreen(),
                        transitionDuration: const Duration(milliseconds: 180),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                      ),
                    );
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────
  Widget _buildHeader(AppColorPalette palette) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.5))),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.25),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Icon(Icons.arrow_back, color: palette.primary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (b) => palette.titleGradient.createShader(b),
                      child: const Text(
                        'Ajustes',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                  Icon(Icons.settings_rounded, color: palette.secondary, size: 26),
                ],
              ),
            ),
          ),
        ),
      ),
    )
    .animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0);
  }

  // ─── Título de sección ────────────────────────────────────────────────
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
    );
  }

  // ─── Grilla de paletas de color ───────────────────────────────────────
  Widget _colorGrid(AppColorPalette current) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: AppPalettes.all.length,
      itemBuilder: (_, i) {
        final palette = AppPalettes.all[i];
        final isSelected = current.id == palette.id;
        return _PaletteCard(
          palette: palette,
          isSelected: isSelected,
          onTap: () => _selectPalette(palette),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: i * 60), duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
      },
    );
  }

  // ─── Vista previa con el tema activo ─────────────────────────────────
  Widget _preview(AppColorPalette palette) {
    return GlassBlurContainer(
      borderRadius: BorderRadius.circular(24),
      addShadow: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mini header
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: palette.iconGradient,
                  ),
                  child: const Icon(Icons.assignment, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (b) => palette.titleGradient.createShader(b),
                    child: Text(
                      palette.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
                Text(palette.emoji, style: const TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(height: 16),
            // Mini task card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: palette.iconGradient,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tarea de ejemplo', style: TextStyle(fontWeight: FontWeight.w600, color: palette.primary, fontSize: 13)),
                        Text('Fecha: hoy', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Mini button
            Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: palette.buttonGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: palette.light.withOpacity(0.4), blurRadius: 12)],
              ),
              child: const Center(
                child: Text('Guardar Tarea', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    )
    .animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  // ─── Botón de cerrar sesión ───────────────────────────────────────────
  Widget _logoutButton(AppColorPalette palette) {
    return GestureDetector(
      onTap: _logout,
      child: GlassBlurContainer(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.red, size: 22),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.red)),
                    Text('Volver a la pantalla de inicio', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.red.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    )
    .animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2, end: 0);
  }
}

// ─── Tarjeta de paleta ────────────────────────────────────────────────────────
class _PaletteCard extends StatelessWidget {
  final AppColorPalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteCard({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? palette.primary : Colors.white.withOpacity(0.4),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: palette.primary.withOpacity(0.35), blurRadius: 14, spreadRadius: 1)]
              : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(isSelected ? 0.6 : 0.35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Círculo de gradiente
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isSelected ? 42 : 36,
                    height: isSelected ? 42 : 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: palette.titleGradient,
                      boxShadow: [BoxShadow(color: palette.primary.withOpacity(0.4), blurRadius: 8)],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    palette.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    palette.name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? palette.primary : const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
