// lib/theme/color_theme.dart
//
// Sistema de temas de color dinámico.
// Permite cambiar TODA la paleta de la app en tiempo real.
// Usa InheritedWidget (el sistema nativo de Flutter para propagar estado hacia abajo).

import 'package:flutter/material.dart';
import 'dart:ui';

// ─── Definición de una paleta de color ───────────────────────────────────────
class AppColorPalette {
  final String id;
  final String name;
  final Color primary;       // Color dominante (e.g. blue600)
  final Color secondary;     // Color de acento (e.g. cyan500)
  final Color light;         // Versión clara (e.g. blue400)
  final Color lighter;       // Aún más clara (e.g. cyan400)
  final List<Color> background; // Gradiente de fondo (5 colores)
  final String emoji;

  const AppColorPalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.light,
    required this.lighter,
    required this.background,
    required this.emoji,
  });

  LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: background,
    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  LinearGradient get titleGradient => LinearGradient(colors: [primary, secondary]);

  LinearGradient get buttonGradient => LinearGradient(colors: [light, secondary, light]);

  LinearGradient get iconGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [light, lighter],
  );
}

// ─── Paletas disponibles ──────────────────────────────────────────────────────
class AppPalettes {
  static const ocean = AppColorPalette(
    id: 'ocean',
    name: 'Océano',
    emoji: '🌊',
    primary:   Color(0xFF2563EB),
    secondary: Color(0xFF06B6D4),
    light:     Color(0xFF60A5FA),
    lighter:   Color(0xFF22D3EE),
    background: [
      Color(0xFFe0f7ff), Color(0xFFb8e6ff),
      Color(0xFFa8d8f0), Color(0xFFc8f0e8), Color(0xFFe0fff8),
    ],
  );

  static const rose = AppColorPalette(
    id: 'rose',
    name: 'Rosa',
    emoji: '🌸',
    primary:   Color(0xFFBE185D),
    secondary: Color(0xFFEC4899),
    light:     Color(0xFFF472B6),
    lighter:   Color(0xFFFDA4AF),
    background: [
      Color(0xFFfff0f6), Color(0xFFffd6e7),
      Color(0xFFffb3d1), Color(0xFFffe4ec), Color(0xFFfff5f8),
    ],
  );

  static const forest = AppColorPalette(
    id: 'forest',
    name: 'Bosque',
    emoji: '🌿',
    primary:   Color(0xFF15803D),
    secondary: Color(0xFF059669),
    light:     Color(0xFF4ADE80),
    lighter:   Color(0xFF34D399),
    background: [
      Color(0xFFe8fff0), Color(0xFFb8f0cc),
      Color(0xFF9de8ba), Color(0xFFc8f5e0), Color(0xFFe0fff0),
    ],
  );

  static const violet = AppColorPalette(
    id: 'violet',
    name: 'Violeta',
    emoji: '💜',
    primary:   Color(0xFF7C3AED),
    secondary: Color(0xFFA855F7),
    light:     Color(0xFFC084FC),
    lighter:   Color(0xFFE879F9),
    background: [
      Color(0xFFf5f0ff), Color(0xFFe8d5ff),
      Color(0xFFd8b8ff), Color(0xFFede0ff), Color(0xFFf8f0ff),
    ],
  );

  static const sunset = AppColorPalette(
    id: 'sunset',
    name: 'Sunset',
    emoji: '🌅',
    primary:   Color(0xFFEA580C),
    secondary: Color(0xFFF59E0B),
    light:     Color(0xFFFB923C),
    lighter:   Color(0xFFFCD34D),
    background: [
      Color(0xFFfff7ed), Color(0xFFfedab0),
      Color(0xFFfdc584), Color(0xFFfde8c0), Color(0xFFfff5e8),
    ],
  );

  static const arctic = AppColorPalette(
    id: 'arctic',
    name: 'Ártico',
    emoji: '🧊',
    primary:   Color(0xFF0E7490),
    secondary: Color(0xFF0891B2),
    light:     Color(0xFF38BDF8),
    lighter:   Color(0xFF7DD3FC),
    background: [
      Color(0xFFe0f8ff), Color(0xFFb0e8f8),
      Color(0xFF90d8f0), Color(0xFFc0eef8), Color(0xFFe0f8ff),
    ],
  );

  static const cherry = AppColorPalette(
    id: 'cherry',
    name: 'Cereza',
    emoji: '🍒',
    primary:   Color(0xFFDC2626),
    secondary: Color(0xFFE11D48),
    light:     Color(0xFFF87171),
    lighter:   Color(0xFFFCA5A5),
    background: [
      Color(0xFFfff0f0), Color(0xFFffd6d6),
      Color(0xFFffb8b8), Color(0xFFffe4e4), Color(0xFFfff8f8),
    ],
  );

  static const midnight = AppColorPalette(
    id: 'midnight',
    name: 'Medianoche',
    emoji: '🌙',
    primary:   Color(0xFF4F46E5),
    secondary: Color(0xFF6366F1),
    light:     Color(0xFF818CF8),
    lighter:   Color(0xFFA5B4FC),
    background: [
      Color(0xFFf0f0ff), Color(0xFFdddcff),
      Color(0xFFc8c5ff), Color(0xFFe0dfff), Color(0xFFf5f5ff),
    ],
  );

  static const List<AppColorPalette> all = [
    ocean, rose, forest, violet, sunset, arctic, cherry, midnight,
  ];
}

// ─── InheritedWidget para propagar el tema ────────────────────────────────────
// Funciona como Context/Provider en React: cualquier widget puede leer el tema
// con AppThemeScope.of(context)

class AppThemeScope extends InheritedNotifier<AppThemeNotifier> {
  const AppThemeScope({
    super.key,
    required AppThemeNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  // Método estático para leer el tema desde cualquier widget
  static AppThemeNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope no encontrado en el árbol de widgets');
    return scope!.notifier!;
  }

  // Lee sin suscribirse a cambios (útil para builders que ya se rebuildan)
  static AppThemeNotifier read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppThemeScope>();
    return scope!.notifier!;
  }
}

// ─── Notifier: guarda la paleta activa y notifica cambios ────────────────────
class AppThemeNotifier extends ChangeNotifier {
  AppColorPalette _palette;

  AppThemeNotifier(this._palette);

  AppColorPalette get palette => _palette;

  void setPalette(AppColorPalette p) {
    if (_palette.id == p.id) return;
    _palette = p;
    notifyListeners();
  }
}

// ─── GlassBlurContainer dinámico ─────────────────────────────────────────────
// Versión mejorada que usa el color del tema activo para el shadow
enum GlassType { normal, strong, light }

class GlassBlurContainer extends StatelessWidget {
  final Widget child;
  final GlassType type;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool addShadow;

  const GlassBlurContainer({
    super.key,
    required this.child,
    this.type = GlassType.normal,
    this.borderRadius,
    this.padding,
    this.addShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    // Leemos la paleta activa del tema
    final palette = AppThemeScope.of(context).palette;

    final Color bgColor = switch (type) {
      GlassType.strong => Colors.white.withOpacity(0.6),
      GlassType.light  => Colors.white.withOpacity(0.25),
      GlassType.normal => Colors.white.withOpacity(0.4),
    };
    final Color borderColor = switch (type) {
      GlassType.strong => Colors.white.withOpacity(0.5),
      GlassType.light  => Colors.white.withOpacity(0.2),
      GlassType.normal => Colors.white.withOpacity(0.3),
    };

    final radius = borderRadius ?? BorderRadius.circular(24);

    Widget container = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
            border: Border.all(color: borderColor),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    if (addShadow) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              // Shadow usa el color primario del tema activo
              color: palette.light.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: container,
      );
    }
    return container;
  }
}

// ─── GlassContainer (sin blur, más ligero) ───────────────────────────────────
class GlassContainer extends StatelessWidget {
  final Widget child;
  final GlassType type;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.type = GlassType.normal,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = switch (type) {
      GlassType.strong => Colors.white.withOpacity(0.6),
      GlassType.light  => Colors.white.withOpacity(0.25),
      GlassType.normal => Colors.white.withOpacity(0.4),
    };
    final Color borderColor = switch (type) {
      GlassType.strong => Colors.white.withOpacity(0.5),
      GlassType.light  => Colors.white.withOpacity(0.2),
      GlassType.normal => Colors.white.withOpacity(0.3),
    };

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius ?? BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
