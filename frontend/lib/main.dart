import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: DataMindApp()));
}

class DataMindApp extends ConsumerWidget {
  const DataMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);

    return MaterialApp(
      title: 'DataMind',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      locale: locale,
      home: const SplashScreen(),
    );
  }
}
