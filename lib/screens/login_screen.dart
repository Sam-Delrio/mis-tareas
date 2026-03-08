// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/color_theme.dart';
import 'home_screen.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String? _emailErr;
  String? _passErr;

  AppColorPalette get _pal => AppThemeScope.of(context).palette;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _validEmail(String e) =>
      RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(e);
  bool _validPass(String p) => RegExp(r'^\d{4}$').hasMatch(p);

  void _login() {
    final pal = _pal;
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    setState(() {
      _emailErr = email.isEmpty
          ? 'Ingresa tu correo'
          : (!_validEmail(email)
              ? 'Formato inválido. Ej: usuario@correo.com'
              : null);
      _passErr = pass.isEmpty
          ? 'Ingresa tu contraseña'
          : (!_validPass(pass) ? 'La contraseña debe ser de 4 dígitos' : null);
    });
    if (_emailErr == null && _passErr == null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = _pal;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        _top(pal),
        Expanded(child: _form(pal)),
      ]),
    );
  }

  Widget _top(AppColorPalette pal) => Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [pal.light, pal.primary, pal.secondary, pal.lighter],
        )),
        child: Stack(children: [
          Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08)),
              )),
          Positioned(
              bottom: 20,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06)),
              )),
          Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                const SizedBox(height: 40),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.school_rounded,
                      size: 60, color: Colors.white),
                )
                    .animate()
                    .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.elasticOut)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _floatIcon(Icons.book_rounded, 200),
                  const SizedBox(width: 20),
                  _floatIcon(Icons.assignment_rounded, 400),
                  const SizedBox(width: 20),
                  _floatIcon(Icons.star_rounded, 600),
                ]),
              ])),
        ]),
      );

  Widget _floatIcon(IconData icon, int delay) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      )
          .animate(delay: Duration(milliseconds: delay))
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.3, end: 0);

  Widget _form(AppColorPalette pal) => Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            ShaderMask(
              shaderCallback: (b) => pal.titleGradient.createShader(b),
              child: const Text('Mis Tareas',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2, end: 0),
            const SizedBox(height: 28),
            _inputField(pal,
                    controller: _emailCtrl,
                    hint: 'Ingresa correo o usuario',
                    icon: Icons.email_outlined,
                    errorText: _emailErr,
                    keyboardType: TextInputType.emailAddress)
                .animate()
                .fadeIn(delay: 300.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 16),
            _passField(pal)
                .animate()
                .fadeIn(delay: 400.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 28),
            _loginBtn(pal)
                .animate()
                .fadeIn(delay: 500.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('¿No tienes cuenta? ',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ShaderMask(
                shaderCallback: (b) => pal.titleGradient.createShader(b),
                child: const Text('¡Regístrate aquí!',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.white)),
              ),
            ]).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('o continúa con',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12))),
              Expanded(child: Divider(color: Colors.grey[300])),
            ]).animate().fadeIn(delay: 700.ms),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _socialBtn(Icons.facebook, const Color(0xFF1877F2)),
              const SizedBox(width: 16),
              _socialBtn(Icons.apple, Colors.black),
              const SizedBox(width: 16),
              _socialBtn(Icons.g_mobiledata_rounded, const Color(0xFFEA4335),
                  size: 30),
            ]).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
          ]),
        ),
      );

  Widget _inputField(
    AppColorPalette pal, {
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border(
                bottom: BorderSide(
                    color: errorText != null ? Colors.red : pal.secondary,
                    width: 2)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: (_) => setState(() => _emailErr = null),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(icon, color: pal.light, size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
          ),
        ),
        if (errorText != null)
          Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(errorText,
                  style: const TextStyle(color: Colors.red, fontSize: 11))),
      ]);

  Widget _passField(AppColorPalette pal) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border(
                bottom: BorderSide(
                    color: _passErr != null ? Colors.red : pal.secondary,
                    width: 2)),
          ),
          child: TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4)
            ],
            onChanged: (_) => setState(() => _passErr = null),
            decoration: InputDecoration(
              hintText: 'Contraseña (4 dígitos)',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(Icons.lock_outline, color: pal.light, size: 20),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey[400],
                    size: 20),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
          ),
        ),
        if (_passErr != null)
          Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(_passErr!,
                  style: const TextStyle(color: Colors.red, fontSize: 11))),
      ]);

  Widget _loginBtn(AppColorPalette pal) => GestureDetector(
        onTap: _login,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: pal.buttonGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: pal.light.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 6))
            ],
          ),
          child: const Center(
              child: Text('Iniciar Sesión',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5))),
        ),
      );

  Widget _socialBtn(IconData icon, Color color, {double size = 24}) =>
      Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)
          ],
        ),
        child: Icon(icon, color: color, size: size),
      );
}
