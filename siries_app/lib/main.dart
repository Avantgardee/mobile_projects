import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Email Verification',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
        backgroundColor: Colors.yellow, // Жёлтый фон AppBar
        foregroundColor: Colors.black, // Чёрный текст и значки
        elevation: 0, // Убирает тень, если не нужна
        titleTextStyle: const TextStyle(
        color: Colors.black, // Чёрный цвет текста
        fontSize: 20, // Размер текста
        fontWeight: FontWeight.bold, // Жирный текст
    )),
        colorScheme: ColorScheme(
          primary: const Color.fromRGBO(255, 193, 7, 1),  // Ваш основной цвет
          secondary: const Color.fromRGBO(255, 193, 7, 1), // Пример вторичного цвета
          background: const Color.fromRGBO(32, 117, 62, 1), // Цвет фона
          surface: Colors.white, // Цвет поверхности (например, фон карточек)
          error: Colors.red, // Цвет ошибки
          onPrimary: Colors.white, // Цвет текста поверх основного цвета
          onSecondary: Colors.black, // Цвет текста поверх вторичного цвета
          // Цвет текста поверх фона
          onSurface: Colors.black, // Цвет текста поверх поверхности
          onError: Colors.white, // Цвет текста поверх ошибки
          brightness: Brightness.light, // Освещенность темы
        ),

        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}
