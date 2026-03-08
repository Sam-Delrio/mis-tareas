import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/color_theme.dart';
import 'models/task_store.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  final prefs = await SharedPreferences.getInstance();
  final savedId = prefs.getString('colorPalette') ?? 'ocean';
  final saved = AppPalettes.all.firstWhere(
    (p) => p.id == savedId,
    orElse: () => AppPalettes.ocean,
  );
  runApp(TaskManagerApp(initialPalette: saved));
}

class TaskManagerApp extends StatefulWidget {
  final AppColorPalette initialPalette;
  const TaskManagerApp({super.key, required this.initialPalette});
  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  late final AppThemeNotifier _themeNotifier;
  final TaskStore _taskStore = TaskStore();

  @override
  void initState() {
    super.initState();
    _themeNotifier = AppThemeNotifier(widget.initialPalette);
    _themeNotifier.addListener(() => setState(() {}));
    // Carga inicial de tareas
    _taskStore.load();
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    _taskStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = _themeNotifier.palette;
    // Ambos scopes envuelven TODA la app:
    // - AppThemeScope  → tema de color
    // - TaskStoreScope → estado de tareas
    return AppThemeScope(
      notifier: _themeNotifier,
      child: TaskStoreScope(
        store: _taskStore,
        child: MaterialApp(
          title: 'Task Manager',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: pal.primary),
            scaffoldBackgroundColor: Colors.transparent,
          ),
          builder: (context, child) {
            final palette = _themeNotifier.palette;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(gradient: palette.backgroundGradient),
              child: child!,
            );
          },
          home: const LoginScreen(),
        ),
      ),
    );
  }
}
