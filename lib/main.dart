import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ControleMateriaisApp());
}

class ControleMateriaisApp extends StatelessWidget {
  const ControleMateriaisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Materiais',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
