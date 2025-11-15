import 'package:flutter/material.dart';

import 'screens/pitch_list_screen.dart';
import 'services/api_client.dart';

class PitchBookingApp extends StatefulWidget {
  const PitchBookingApp({super.key});

  @override
  State<PitchBookingApp> createState() => _PitchBookingAppState();
}

class _PitchBookingAppState extends State<PitchBookingApp> {
  late final ApiClient _apiClient;
  late final ValueNotifier<ThemeMode> _themeMode;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _themeMode = ValueNotifier(ThemeMode.system);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Pitch Booking',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF1B5E20),
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFF66BB6A),
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          home: PitchListScreen(
            apiClient: _apiClient,
            onToggleTheme: _toggleTheme,
            themeMode: themeMode,
          ),
        );
      },
    );
  }

  void _toggleTheme() {
    final isDark = _themeMode.value == ThemeMode.dark;
    _themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  @override
  void dispose() {
    _themeMode.dispose();
    _apiClient.dispose();
    super.dispose();
  }
}
