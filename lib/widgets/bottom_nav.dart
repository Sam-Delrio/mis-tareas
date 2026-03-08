// lib/widgets/bottom_nav.dart

import 'package:flutter/material.dart';
import '../theme/color_theme.dart';
import 'dart:ui';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabSelected;

  const BottomNav({super.key, this.currentIndex = 0, this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeScope.of(context).palette;

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28), topRight: Radius.circular(28),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28), topRight: Radius.circular(28),
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                  boxShadow: [BoxShadow(color: palette.light.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.transparent, palette.light, Colors.transparent]),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(icon: Icons.home_rounded,           label: 'Inicio',      isActive: currentIndex == 0, palette: palette, onTap: () => onTabSelected?.call(0)),
                        _NavItem(icon: Icons.calendar_month_rounded,  label: 'Calendario',  isActive: currentIndex == 1, palette: palette, onTap: () => onTabSelected?.call(1)),
                        _NavItem(icon: Icons.settings_rounded,        label: 'Ajustes',     isActive: currentIndex == 2, palette: palette, onTap: () => onTabSelected?.call(2)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final AppColorPalette palette;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.label,
    this.isActive = false, required this.palette, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                gradient: LinearGradient(colors: [palette.light.withOpacity(0.2), palette.lighter.withOpacity(0.2)]),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: isActive ? palette.primary : Colors.grey[500]),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isActive ? palette.primary : Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}
