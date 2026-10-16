import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

const red = Color(0xFFCF101B);
const background = Color(0xFFFAF8F6);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Red Anáhuac · CONEVAL',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: background,
          fontFamily: 'Arial',
          colorScheme: ColorScheme.fromSeed(seedColor: red, primary: red),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE7DED9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE7DED9)),
            ),
          ),
        ),
        builder: (context, child) => ColoredBox(
          color: const Color(0xFFEDE9E5),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child!,
            ),
          ),
        ),
        home: const SplashPage(),
      );
}